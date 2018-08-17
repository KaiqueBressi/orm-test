module Obstinacy
  class PersistenceModel
    attr_reader :sequel_model, :flagged_as, :entity, :relationship_collection, :foreign_key

    def initialize(sequel_model, entity, relationship_collection = nil, foreign_key = nil)
      @sequel_model = sequel_model
      @entity = entity
      @relationship_collection = relationship_collection
      @flagged_as = :clean
      @foreign_key = foreign_key
    end

    def save_changes
      case @flagged_as
      when :new, :dirty
        sequel_model.save_changes

        iterate_over_relationships do |relationship|
          relationship_fk = relationship.foreign_key
          relationship.send("#{relationship_fk}=", sequel_model.id)
          relationship.save_changes
        end
      when :deleted
        iterate_over_relationships do |relationship|
          relationship.save_changes
        end

        sequel_model.delete
      when :clean
      end
    end

    def ==(other)
      self.id == other.id
    end

    def flag_as(flag)
      @flagged_as = flag

      iterate_over_relationships do |relationship|
        relationship.flag_as(flag)
      end
    end

    def method_missing(method, *args)
      @sequel_model.send(method, *args)
    end

    def compare_and_mark(persistence_model)

    end

    private

    def iterate_over_relationships(&block)
      @relationship_collection.each do |relationships|
        relationships.each do |relationship|
          yield relationship
        end
      end
    end
  end
end
