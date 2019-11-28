require_relative 'manufacturer.rb'
require_relative 'carriage.rb'
require_relative 'railway_error.rb'

class PassengerCarriage < Carriage
  CARRIAGE_TYPE = 'passenger'.freeze

  def initialize(num_of_seats, number = generate_number(LENGTH))
    super number
    @type = CARRIAGE_TYPE
    @number_of_seats = Hash.new
    @number_of_seats[:total] = num_of_seats.to_i
    @number_of_seats[:taken] = 0
  end

  def take_seat
    no_seats_error = "There are no empty seats in carriage '#{number}'"
    raise RailwayError, no_seats_error unless free_seats?

    @number_of_seats[:taken] += 1
  end

  def number_of_seats
    @number_of_seats[:total]
  end

  def free_seats
    @number_of_seats[:total] - @number_of_seats[:taken]
  end

  def taken_seats
    @number_of_seats[:taken]
  end

  private
  def free_seats?
    free_seats.positive?
  end
end
