require_relative 'obstinacy'
require 'securerandom'

DB = Sequel.sqlite
Sequel::Model.unrestrict_primary_key

DB.create_table :legal_risk_analysis_legal_references do
  primary_key :id, auto_increment: false, type: String
  String :application_id
end

DB.logger = Logger.new($stdout)

DB.create_table :legal_risk_analysis_real_estates do
  primary_key :id, auto_increment: false, type: String
  foreign_key :legal_reference_id, :legal_risk_analysis_legal_references, null: false
  String :type
  TrueClass :alienated
  TrueClass :condominium
end

DB.create_table :legal_risk_analysis_addresses do
  primary_key :id, auto_increment: false, type: String
  foreign_key :real_estate_id, :legal_risk_analysis_real_estates, null: false

  String :street
  String :number
  String :complement
  String :neighborhood
  String :city
  String :state
  String :zip_code
end

class LegalReference
  attr_reader :id, :real_estates, :application_id

  def initialize(application_id:)
    @id = SecureRandom.uuid
    @application_id = application_id
    @real_estates = []
  end

  def add_real_estate(real_estate)
    @real_estates << real_estate
  end

  def remove_real_estate(real_estate_id)
    @real_estates.reject! { |real_estate| real_estate.id == real_estate_id }
  end
end

class RealEstate
  attr_reader :id, :address
  attr_accessor :type, :alienated, :condominium

  def initialize(type:, alienated:, condominium:, address:)
    @id = SecureRandom.uuid
    @type = type
    @alienated = alienated
    @condominium = condominium
    @address = [address]
  end
end

class Address
  attr_reader :street, :number, :complement, :neighborhood, :city, :state, :zip_code, :id

  def initialize(street:, number:, complement:, neighborhood:, city:, state:, zip_code:)
    @id = SecureRandom.uuid
    @street = street
    @number = number
    @complement = complement
    @neighborhood = neighborhood
    @city = city
    @state = state
    @zip_code = zip_code
  end
end

Obstinacy.configure do
  mapping do
    mapper_for RealEstate do
      attribute :id
      foreign_key :legal_reference_id

      attribute :type
      attribute :alienated
      attribute :condominium
      has_many :address, Address

      table :legal_risk_analysis_real_estates
    end

    mapper_for LegalReference do
      attribute :id
      attribute :application_id
      has_many :real_estates, RealEstate

      table :legal_risk_analysis_legal_references
    end

    mapper_for Address do
      attribute :id
      foreign_key :real_estate_id

      attribute :street
      attribute :number
      attribute :complement
      attribute :neighborhood
      attribute :city
      attribute :state
      attribute :zip_code

      table :legal_risk_analysis_addresses
    end
  end
end

address = Address.new(street: 'rua', number: 'numero', complement: 'complemento', neighborhood: 'bairro', city: 'São Paulo', state: 'SP', zip_code: '08320-310')
real_estate = RealEstate.new(type: 'apartment', alienated: true, condominium: true, address: address)

address = Address.new(street: 'ruasssss', number: 'numerosss', complement: 'complementossss', neighborhood: 'bairrossss', city: 'São Paulo', state: 'SP', zip_code: '08320-310')
real_estate2 = RealEstate.new(type: 'terrain', alienated: false, condominium: false, address: address)

legal_reference = LegalReference.new(application_id: '2ef6dbfa-912e-11e8-a32f-33db79903c4e')
legal_reference.add_real_estate(real_estate)
legal_reference.add_real_estate(real_estate2)

session = Obstinacy::Session.new
session.create(legal_reference)
session.commit

new_legal_reference = session.find(legal_reference.id, LegalReference)
new_legal_reference.remove_real_estate(real_estate.id)

session.update(new_legal_reference)
session.commit

require "byebug"
byebug

puts ""


