module Obstinacy
  class ValueObject
    attr_reader :attribute_name, :value_object_class

    def initialize(attribute_name, value_object_class)
      @attribute_name = attribute_name
      @value_object_class = value_object_class
    end

    def mapper
      @mapper ||= Obstinacy.configuration.mappings[@value_object_class]
    end
  end
end
