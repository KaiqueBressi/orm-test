module Obstinacy
  class PersistenceModel 
    attr_reader :sequel_model, :flaggued_as, :entity, :relationships, :foreign_key

    def initialize(sequel_model, entity, relationships = nil, foreign_key = nil)
      @sequel_model = sequel_model
      @entity = entity
      @relationships = relationships
      @flaggued_as = :new
      @foreign_key = foreign_key
    end

    def save_changes
      if (@flaggued_as == :new) || (@flaggued_as == :dirty)
        sequel_model.save_changes

        relationships.each do |relationship_collection|
          relationship_collection.each do |relationship|
            relationship_fk = relationship.foreign_key
            relationship.send("#{relationship_fk}=", sequel_model.id)
            relationship.save_changes
          end
        end
      end
    end

    def ==(other)
      self.id == other.id
    end

    def method_missing(method, *args)
      @sequel_model.send(method, *args)
    end
  end
end
