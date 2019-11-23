require_relative 'manufacturer.rb'
require_relative 'carriage.rb'
require_relative 'railway_error.rb'

class CargoCarriage < Carriage
  CARRIAGE_TYPE = 'cargo'

  def initialize(carriage_number = generate_number(LENGTH), max_cargo_volume)
    super carriage_number
    @type = CARRIAGE_TYPE
    @volume = Hash.new
    @volume[:max] = max_cargo_volume
    @volume[:taken] = 0
  end

  def place_cargo(volume)
    no_space_error = "Not enough space to place your cargo!"
    raise RailwayError, no_space_error unless
  end
end
