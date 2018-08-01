require_relative 'obstinacy'

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

class Address
  attr_reader :street, :number, :complement, :neighborhood, :city, :state, :zip_code

  def initialize(street:, number:, complement:, neighborhood:, city:, state:, zip_code:)
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
      attribute :type
      attribute :alienated
      attribute :condominium
      value_object :address, Address

      table :legal_risk_analysis_real_estates
    end

    mapper_for LegalReference do
      attribute :application_id
      has_many :real_estates, RealEstate

      table :legal_risk_analysis_legal_references
    end

    mapper_for Address do
      attribute :type
      attribute :alienated
      attribute :condominium
    end
  end
end

session = Obstinacy::Session.new

puts Obstinacy.configuration.mappings.map(&:inspect)
