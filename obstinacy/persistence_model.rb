module Obstinacy
  class PersistenceModel < SimpleDelegator
    attr_reader :sequel_model, :flagged_as, :relationship_collection

    def initialize(sequel_model, relationship_collection)
      @sequel_model = sequel_model
      @relationship_collection = relationship_collection
      @flagged_as = :clean

      super(sequel_model)
    end

    def save_changes
      case @flagged_as
      when :new, :dirty
        sequel_model.save_changes

        iterate_over_relationships do |relationship|
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

    def flagged_as?(flag)
      @flagged_as == flag
    end

    def flag_as(flag)
      @flagged_as = flag

      iterate_over_relationships do |relationship|
        relationship.flag_as(flag)
      end
    end

    private

    def iterate_over_relationships(&block)
      @relationship_collection.each do |key_, relationships|
        relationships.each do |relationship|
          yield relationship
        end
      end
    end
  end
end
