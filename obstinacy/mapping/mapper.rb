require_relative 'relationship'
require_relative 'value_object'

module Obstinacy
  class Mapper
    attr_reader :attributes, :relationships, :value_objects, :entity_class, :repository_class, :table_name

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

    def has_many(attribute_name, relationship_class)
      @relationships << Obstinacy::Relationship.new(attribute_name, relationship_class, :has_many)
    end

    def has_one()
      @relationships << Obstinacy::Relationship.new(attribute_name, relationship_class, :has_one)
    end
  end
end
