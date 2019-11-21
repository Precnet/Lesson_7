require_relative 'manufacturer.rb'
require_relative 'carriage.rb'

class PassengerCarriage < Carriage
  CARRIAGE_TYPE = 'passenger'.freeze

  def initialize(carriage_number = generate_carriage_number(NUMBER_LENGTH))
    super carriage_number
    @type = CARRIAGE_TYPE
  end
end
