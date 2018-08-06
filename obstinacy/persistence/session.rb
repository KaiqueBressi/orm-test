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
      mapper = get_mapper_from_entity(entity)


      check_existence
      
      @persistence_models << mapper.to_persistence_model(entity)
    end

    def update(entity)
      mapper = get_mapper_from_entity(entity)
    end

    def commit
      DB.transaction do 
        @persistence_models.each do |persistence_model|
          persistence_model.save_changes
        end
      end
    end

    private

    def exists_in_memory?(entity)
      @persistence_models.detect { |item| item.id == entity.id }
    end

    def get_mapper_from_entity(entity)
      Obstinacy.configuration.mappings[entity.class]
    end
  end
end
