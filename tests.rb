require_relative 'obstinacy'

class LegalReference
  attr_reader :real_estates, :application_id

  def initialize(application_id:)
    @application_id = application_id
    @real_estates = []
  end

  def add_real_estate(real_estate)
    @real_estates << real_estate
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
      attribute :street
      attribute :number
      attribute :complement
      attribute :neighborhood
      attribute :city
      attribute :state
      attribute :zip_code
    end
  end
end

session = Obstinacy::Session.new

legal_reference = LegalReference.new(application_id: '2ef6dbfa-912e-11e8-a32f-33db79903c4e')
address = Address.new(street: 'rua', number: 'numero', complement: 'complemento', neighborhood: 'bairro', city: 'São Paulo', state: 'SP', zip_code: '08320-310')
real_estate = RealEstate.new(type: 'apartment', alienated: true, condominium: true, address: address)

legal_reference.add_real_estate(real_estate)

session.create(legal_reference)

session.commit
