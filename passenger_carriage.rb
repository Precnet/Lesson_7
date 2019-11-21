require_relative 'manufacturer.rb'
require_relative 'carriage.rb'

class PassengerCarriage < Carriage
  CARRIAGE_TYPE = 'passenger'.freeze

  def initialize(number = generate_number(LENGTH))
    super number
    @type = CARRIAGE_TYPE
  end
end
