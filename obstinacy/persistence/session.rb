require 'sequel'
require 'logger'
require_relative 'persistence_model'

module Obstinacy
  class Session
    attr_reader :persistence_models

    def initialize
      @persistence_models = []
    end

    def create(entity)
      mapper = get_mapper_from_entity_class(entity.class)

      if exists_in_memory?(entity.id)
        fail 'entity already exists on data base'
      end

      persistence_model = mapper.to_persistence_model(entity)
      persistence_model.flag_as(:dirty)

      @persistence_models << persistence_model
    end

    def update(entity)
      mapper = get_mapper_from_entity_class(entity.class)

      in_memory = exists_in_memory?(entity.id)
      fail 'object not attached to the session' unless in_memory

      case in_memory.flagged_as
      when :dirty
        index = @persistence_models.index { |persistence_model| persistence_model.id == entity.id }

        @persistence_models[index] = mapper.to_persistence_model(entity)
      when :clean
        persistence_model = mapper.to_persistence_model(entity)

        in_memory.compare_and_mark(persistence_model)
      end
    end

    def delete(entity)
      persistence_model = exists_in_memory?(entity)
      fail 'object not attached to the session' unless persistence_model

      persistence_model.flag_as(:deleted)
    end

    def find(id, entity_class)
      persistence_model = exists_in_memory?(id)
      return persistence_model&.entity if persistence_model

      mapper = get_mapper_from_entity_class(entity_class)

      sequel_model = Sequel::Model(mapper.table_name).where(id: id).first

      entity = mapper.to_entity(sequel_model)
      set_relationships(entity, mapper.relationships)

      persistence_model = mapper.to_persistence_model(entity)
      persistence_model.flag_as(:clean)

      @persistence_models << persistence_model
      entity
    end

    def commit
      DB.transaction do
        @persistence_models.each do |persistence_model|
          persistence_model.save_changes
        end
      end

      @persistence_models.clear
    end

    private

    def set_relationships(entity, relationships)
      relationships.each do |relationship|
        relationship_mapper = relationship.mapper
        entity.instance_variable_set("@#{relationship.attribute_name}", [])

        relationships_models = Sequel::Model(relationship_mapper.table_name).where(relationship_mapper.foreign_key_name => entity.id).all
        relationships_models.each do |relationship_model|
          relationship_entity = relationship_mapper.to_entity(relationship_model)

          set_relationships(relationship_entity, relationship_mapper.relationships)

          entity.instance_variable_get("@#{relationship.attribute_name}").send(:<<, relationship_entity)
        end
      end

      entity
    end

    def exists_in_memory?(id)
      @persistence_models.detect { |persistence_model| persistence_model.id == id }
    end

    def get_mapper_from_entity_class(entity_class)
      Obstinacy.configuration.mappings[entity_class]
    end
  end
end
