require_relative 'relationship'
require_relative 'value_object'
require_relative '../persistence/persistence_model'

module Obstinacy
  class Mapper
    attr_reader :attributes, :relationships, :value_objects, :entity_class, :repository_class, :table_name, :foreign_key

    def initialize(entity_class, &block)
      @attributes = []
      @relationships = []
      @value_objects = []
      @entity_class = entity_class
      instance_eval(&block)
    end

    def repository(repository_class)
      @repository_class = repository_class
    end

    def table(table_name)
      @table_name = table_name
    end

    def attribute(attribute_name)
      @attributes << attribute_name
    end

    def value_object(attribute_name, value_object_class)
      @value_objects << Obstinacy::ValueObject.new(attribute_name, value_object_class)
    end

    def foreign_key(foreign_key)
      @foreign_key = foreign_key
    end

    def has_many(attribute_name, relationship_class)
      @relationships << Obstinacy::Relationship.new(attribute_name, relationship_class, :has_many)
    end

    def has_one
      @relationships << Obstinacy::Relationship.new(attribute_name, relationship_class, :has_one)
    end

    def map_from_entity(entity)
      persistence_model = {}
      persistence_model.merge!(map_attributes(entity))
      persistence_model.merge!(map_value_objects(entity))
    end

    def to_persistence_model(entity)
      attributes = map_from_entity(entity)

      sequel_model = Sequel::Model(@table_name).new(attributes)
      Obstinacy::PersistenceModel.new(sequel_model, entity, relationships_to_persistence_model(entity), @foreign_key)
    end

    private

    def relationships_to_persistence_model(entity)
      @relationships.map do |relationship|
        relationship_entities = entity.send(relationship.attribute_name)

        if relationship.type == :has_many
          relationship_entities.map do |relationship_entity|
            relationship.mapper.to_persistence_model(relationship_entity)
          end
        else
          [relationship.mapper.to_persistence_model(relationship_entity)]
        end
      end
    end

    def map_attributes(entity)
      @attributes.each_with_object({}) do |attribute, persistence_model|
        persistence_model[attribute] = entity.send(attribute)
      end
    end

    def map_value_objects(entity)
      @value_objects.each_with_object({}) do |value_object, persistence_model|
        value_object_mapper = value_object.mapper
        persistence_model.merge!(value_object_mapper.map_from_entity(entity.send(value_object.attribute_name)))
      end
    end
  end
end
