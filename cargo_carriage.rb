require_relative 'manufacturer.rb'
require_relative 'carriage.rb'
require_relative 'railway_error.rb'

class CargoCarriage < Carriage
  CARRIAGE_TYPE = 'cargo'

  def initialize(number = generate_number(LENGTH), max_cargo_volume)
    super number
    @type = CARRIAGE_TYPE
    @volume = Hash.new
    @volume[:max] = max_cargo_volume.to_i
    @volume[:taken] = 0
  end

  def place_cargo(volume)
    no_space_error = "Not enough space to place your cargo!"
    raise RailwayError, no_space_error unless free_volume - volume >= 0

    @volume[:taken] += volume
  end

  def cargo_capacity
    @volume[:max]
  end

  def free_volume
    @volume[:max] - @volume[:taken]
  end

  def occupied_volume
    @volume[:taken]
  end
end
