require_relative 'mapper'

module Obstinacy
  class MapperRegistry
    attr_reader :mappings

    def initialize
      @mappings = {}
    end

    def mapping(&block)
      instance_eval(&block)

      check_mappers
    end

    def mapper_for(entity_class, &block)
      @mappings[entity_class] = Obstinacy::Mapper.new(entity_class, &block)
    end

    private

    def check_mappers
      attributes = @mappings.values.flat_map { |mapper| mapper.relationships + mapper.value_objects }

      attributes.each do |attribute|
        raise "Mapper for property :#{attribute.attribute_name} not found" unless attribute.mapper
      end
    end
  end
end
