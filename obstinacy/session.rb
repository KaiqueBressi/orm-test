require 'sequel'

Sequel.connect('postgres://postgres@localhost:5432/bankfacil_core_development')

module Obstinacy
  class Session
    def initialize

    end
  end
end
