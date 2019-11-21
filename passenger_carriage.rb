require_relative 'manufacturer.rb'
require_relative 'carriage.rb'

class PassengerCarriage < Carriage
  CARRIAGE_TYPE = 'passenger'.freeze

  attr_reader :num_of_seats

  def initialize(number = generate_number(LENGTH), num_of_seats)
    super number
    @type = CARRIAGE_TYPE
    @num_of_seats = num_of_seats
  end
end
