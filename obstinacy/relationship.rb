module Obstinacy
  class Relationship
    attr_reader :attribute_name, :entity_class, :type, :mapper

    def initialize(attribute_name, entity_class, type)
      @attribute_name = attribute_name
      @entity_class = entity_class
      @type = type
    end

    def mapper
      @mapper ||= Obstinacy.configuration.mappings[@entity_class]
    end
  end
end
