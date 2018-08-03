module Obstinacy
  class InMemoryEntity
    attr_reader :persistence_model, :flaggued_as, :entity_class, :relationships

    def initialize(persistence_model, entity_class, relationships = nil)
      @persistence_model = persistence_model
      @entity_class = entity_class
      @relationships = relationships
      @flaggued_as = :new
    end
  end
end
