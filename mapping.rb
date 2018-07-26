require 'sequel'
require 'transproc'

Sequel.connect('postgres://postgres@localhost:5432/bankfacil_core_development')

class Mapper
  attr_reader :entity

  def self.[](entity_class)
    mapper_class = Class.new(Mapper)
    mapper_class.entity_class = entity_class
    mapper_class
  end

  def self.inherited(subclass)
    subclass.entity_class = @entity_class
  end

  def self.mapping(table, &block)
    @table = table

    instance_eval(&block)
  end

  def self.entity_class=(entity_class)
    @entity_class = entity_class
  end

  def self.attribute(attribute)
    attributes << attribute
  end

  def self.has_many(attribute, relationship_entity)
    relationships << { attribute => relationship_entity }
  end

  def self.relationships
    @relationships ||= []
  end

  def self.attributes
    @attributes ||= []
  end

  def self.table
    @table
  end

  def self.map_from(sequel_model)
    entity = @entity_class.allocate

    attributes.each do |attribute|
      entity.instance_variable_set("@#{attribute}".to_sym, sequel_model.send(attribute.to_s))
    end

    entity
  end
end

class Repository
  def self.[](entity_class)
    repository_class = Class.new(Repository)
    repository_class.entity_class = entity_class
    repository_class
  end

  def self.inherited(subclass)
    subclass.entity_class = @entity_class
  end

  def self.entity_class=(entity_class)
    @entity_class = entity_class
  end

  def self.find_by_id(id)
    entity = sequel_model.where(id: id).first

    mapper.map_from(entity)
  end

  def self.mapper
    Object.const_get(@entity_class.name + 'Mapper')
  end

  def self.sequel_model
    Class.new(Sequel::Model(mapper.table))
  end
end

class LegalReference
  attr_reader :real_estates

  def initialize
    @real_estates = []
  end
end

class RealEstate
  attr_reader :type, :alienated, :condominium, :address

  def initialize(type:, alienated:, condominium:, address:)
    @type = type
    @alienated = alienated
    @condominium = condominium
    @address = address
  end
end

class RealEstateMapper < Mapper[RealEstate]
  mapping :legal_risk_analysis_real_estates do
    attribute :type
    attribute :alienated
    attribute :condominium
  end
end

class LegalReferenceMapper < Mapper[LegalReference]
  mapping :legal_risk_analysis_legal_references do
    attribute :application_id

    has_many :real_estates, RealEstate
  end
end

class RealEstatesRepository < Repository[RealEstate]; end;

real_estate = RealEstatesRepository.find_by_id('70cfe022-e317-4b02-81c3-63c9ee497fda')
puts real_estate.inspect
