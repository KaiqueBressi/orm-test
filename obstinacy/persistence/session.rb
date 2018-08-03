require 'sequel'
require 'logger'
require_relative 'in_memory_entity'

DB = Sequel.connect('postgres://postgres@localhost:5432/bankfacil_core_development')
DB.logger = Logger.new($stdout)

module Obstinacy
  class Session
    attr_reader :in_memory_entities

    def initialize
      @in_memory_entities = []
    end

    def create(entity)
      mapper = get_mapper_from_entity(entity)
      mapper.to_persistence_model(entity)

      require "pry-byebug"
      byebug


      attributes = mapper.map_from_entity(entity)

      relationships = create_in_memory_relationships(mapper, entity)
      persistence_model = Sequel::Model(mapper.table_name).new(attributes)
      @in_memory_entities << InMemoryEntity.new(persistence_model, entity.class, relationships)
    end

    def commit
      @in_memory_entities.each do |in_memory_entity|
        in_memory_entity.persistence_model.save_changes
      end
    end

    private

    def create_in_memory_relationships(entity_mapper, entity)
      entity_mapper.relationships.each_with_object([]) do |relationship, result|
        relationship_entities = entity.send(relationship.attribute_name)

        relationship_entities.each do |relationship_entity|
          mapper = relationship.mapper
          attributes = mapper.map_from_entity(relationship_entity)

          persistence_model = Sequel::Model(mapper.table_name).new(attributes)
          result << InMemoryEntity.new(persistence_model, relationship.class)
        end
      end
    end

    def get_mapper_from_entity(entity)
      Obstinacy.configuration.mappings[entity.class]
    end
  end
end
