require_relative 'validator.rb'
require_relative 'railway_error.rb'

# Carriage
class Carriage
  include Manufacturer
  include Validator

  LENGTH = 5
  BASE_36 = 36
  CARRIAGE_TYPE = ''.freeze

  attr_reader :number, :type
  @@carriages = []

  def self.carriages
    @@carriages
  end

  def initialize(carriage_number)
    @number = carriage_number
    validate!
    @@carriages.push(self)
  end

  protected

  def validate!
    validate_carriage_name_type!
    validate_carriage_name_length!
  end

  def validate_carriage_name_type!
    type_message = "Wrong carriage name! Should be string, got #{@number.class}"
    raise RailwayError, type_message unless @number.is_a?(String)
  end

  def validate_carriage_name_length!
    length_message = 'Carriage number should be between 3 and 20 symbols!'
    length_is_correct = @number.length >= 3 && @number.length < 20
    raise RailwayError, length_message unless length_is_correct
  end

  # this is a method for creating default name for carriage it should not
  # be used outside of object constructor
  def generate_number(number_length)
    CARRIAGE_TYPE + '_' + rand(BASE_36**number_length).to_s(BASE_36)
  end
end
