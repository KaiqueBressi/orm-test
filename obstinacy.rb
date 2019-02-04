require_relative 'obstinacy/configuration'
require_relative 'obstinacy/session'
require_relative 'obstinacy/mapper'

module Obstinacy
  def self.configure(&block)
    @configuration ||= Configuration.new
    @configuration.configure(&block)
    @configuration
  end

  def self.configuration
    @configuration
  end

  def self.reset_configuration
    @configuration = nil
  end
end
