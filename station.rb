# frozen_string_literal: true

# station class
require_relative 'instance_counter.rb'
require_relative 'validator.rb'
require_relative 'railway_error.rb'

# station class
class Station
  include InstanceCounter
  include Validator

  attr_reader :name, :trains_at_station
  @@stations = []

  def self.all
    @@stations
  end

  def initialize(station_name)
    @name = station_name
    validate!
    @trains_at_station = []
    register_instance
    @@stations.push(self)
  end

  def train_arrived(new_train)
    @trains_at_station.push(new_train)
  end

  def send_train(train_number)
    error_message = "There is no train with number '#{train_number}' at station"
    raise ArgumentError, error_message unless train_at_station?(train_number)

    train_index = get_train_index_by(train_number)
    @trains_at_station.delete_at(train_index)
  end

  def trains_at_station_of_type(type)
    trains = @trains_at_station.select { |train| train if train.type == type }
    trains.map(&:number)
  end

  def trains_at_station_by_type
    result = {}
    train_types = @trains_at_station.map(&:type)
    train_types.uniq.each { |type| result[type] = train_types.count(type) }
    result
  end

  def each_train
    no_block_error = 'This method requires block to operate!'
    raise RailwayError, no_block_error unless block_given?

    trains_at_station.each { |train| yield train }
  end

  private

  def validate!
    validate_station_name_not_nil!
    validate_station_name_type!
    validate_station_name_empty!
    validate_station_name_length!
  end

  def validate_station_name_not_nil!
    nil_message = 'Station name can`t be nil!'
    raise RailwayError, nil_message unless @name
  end

  def validate_station_name_type!
    type_message = 'Station name should be of String class!'
    raise RailwayError, type_message unless @name.is_a?(String)
  end

  def validate_station_name_empty!
    empty_message = 'Station name can`t be empty!'
    raise RailwayError, empty_message unless @name.length.positive?
  end

  def validate_station_name_length!
    long_message = 'Station name is too long! Should be <= 20 symbols.'
    raise RailwayError, long_message unless @name.length <= 20
  end

  def train_at_station?(train_number)
    @trains_at_station.map(&:number).include? train_number
  end

  def get_train_index_by(train_name)
    @trains_at_station.map(&:number).find_index(train_name)
  end
end
