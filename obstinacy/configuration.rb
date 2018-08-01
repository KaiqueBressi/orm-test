require_relative 'mapping/mapper_registry'

module Obstinacy
  class Configuration
    attr_reader :mapper_registry

    def initialize(&block)
      @mapper_registry = Obstinacy::MapperRegistry.new
    end

    def configure(&block)
      instance_eval(&block)
    end

    def mapping(&block)
      @mapper_registry.mapping(&block)
    end

    def mappings
      @mapper_registry&.mappings || []
    end
  end
end
