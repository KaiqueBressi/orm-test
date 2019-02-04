require 'sequel'
require 'logger'
require_relative 'persistence_model'

module Obstinacy
  class Session
    attr_reader :identity_map

    def initialize
      @identity_map = {}
    end

    def create(entity)
      fail 'entity already exists on data base' if exists_in_memory?(entity.id)

      mapper = get_mapper_from_entity_class(entity.class)

      persistence_model = mapper.to_persistence_model(entity)
      persistence_model.flag_as(:new)

      @identity_map[persistence_model] = entity
    end

    def update(entity)
      persistence_model = exists_in_memory?(entity.id)
      fail 'entity not attached to this session' unless persistence_model

      mapper = get_mapper_from_entity_class(entity.class)

      if persistence_model.flagged_as?(:new)
        @identity_map.delete(persistence_model)

        updated_persistence_model = mapper.to_persistence_model(entity)
        updated_persistence_model.flag_as(:new)

        @identity_map[updated_persistence_model] = entity
      else
        mapper.relationships.each do |relationship|
          relationship_mapper = relationship.mapper
          relationship_persistence_models = persistence_model.relationship_collection[relationship.attribute_name]
          entity_relationship_models = entity.send(relationship.attribute_name)

          relationship_persistence_models.each do |relationship_persistence_model| 
            delete = entity_relationship_models.find { |entity_relationship_model| entity_relationship_model.id == relationship_persistence_model.id }
            
            if delete
              
            end
          end
        end
      end
    end

    def delete(entity)
      persistence_model = exists_in_memory?(entity)
      fail 'object not attached to the session' unless persistence_model

      persistence_model.flag_as(:deleted)
    end

    def find(id, entity_class)
      persistence_model = exists_in_memory?(id)
      return @identity_map[persistence_model] if persistence_model

      entity_mapper = get_mapper_from_entity_class(entity_class)
      sequel_model = Sequel::Model(entity_mapper.table_name).where(id: id).first
      
      persistence_model = PersistenceModel.new(sequel_model, find_relationships(id, entity_mapper.relationships))
      
      @identity_map[persistence_model] = entity_mapper.to_entity(persistence_model)
    end

    def commit
      DB.transaction do
        @identity_map.each do |persistence_model, _entity|
          persistence_model.save_changes
        end
      end

      @identity_map.clear
    end

    private

    def find_relationships(id, relationships)
      relationships.each_with_object({}) do |relationship, persistence_models|
        relationship_mapper = relationship.mapper

        sequel_models = Sequel::Model(relationship_mapper.table_name).where(relationship_mapper.foreign_key_name => id).all
        persistence_models[relationship.attribute_name] = sequel_models.map do |sequel_model|
          PersistenceModel.new(sequel_model, find_relationships(sequel_model.id, relationship_mapper.relationships))
        end
      end
    end

    def exists_in_memory?(id)
      @identity_map.detect do |persistence_model, _entity| 
        persistence_model.id == id
      end&.first
    end

    def get_mapper_from_entity_class(entity_class)
      Obstinacy.configuration.mappings[entity_class]
    end
  end
end
