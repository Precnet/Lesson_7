# frozen_string_literal: true

require_relative 'station.rb'
require_relative 'route.rb'
require_relative 'passenger_train.rb'
require_relative 'cargo_train.rb'
require_relative 'passenger_carriage.rb'
require_relative 'cargo_carriage.rb'
require_relative 'requester.rb'

class UserInterface
  include Requester

  attr_reader :menu_items, :user_data
  def initialize
    @user_data = UserData.new
    @user_action = UserActions.new(@user_data)
  end

  def create_default_menu
    @menu_items = (@user_action.methods - Object.methods).sort
  end

  def main_loop
    loop do
      show_menu
      process_user_input get_user_input.to_i
    end
  end

  def create_menu_item(item, command)
    @menu_items[item] = command
  end

  def show_menu
    puts '--- Main menu ---'
    @menu_items.each_with_index { |item, index| puts(menu_item(item, index)) }
    puts '______ End ______'
    puts
  end

  def select_menu_item(item, args = nil)
    unless @menu_items.include?(item)
      raise ArgumentError, "No such menu item: #{item}!"
    end

    args ? @user_action.send(item, *args) : @user_action.send(item)
  end

  private

  # these methods should not be called outside of class methods
  def get_user_input
    print 'Type index number to select menu item: '
    gets.strip
  end

  def process_user_input(input)
    error = 'There is no such menu item!'
    raise ArgumentError, error unless (1..@menu_items.length).include?(input)

    begin
      method = @menu_items[input - 1]
      parameters = get_request_parameters @user_action.method(method).parameters
      select_menu_item(@menu_items[input - 1], parameters)
    rescue StandardError
      puts $ERROR_INFO.message
      retry
    end
  end

  def menu_item(item, index)
    (index + 1).to_s + ' - ' + item.to_s.capitalize.gsub('_', ' ')
  end
end

class UserActions
  include Requester

  def initialize(user_data)
    @user_data = user_data
  end

  def create_station(station_name)
    station = Station.new(station_name)
    @user_data.stations[station.name] = station
    puts "Created station: #{station.name}"
  end

  def show_existing_stations
    if !@user_data.stations.empty?
      puts 'There are next stations:'
      puts @user_data.stations.keys { |station_name| station_name }.join(', ')
    else
      puts 'There are no stations.'
    end
  end

  def create_cargo_train(train_number = nil)
    train = CargoTrain.new(train_number)
    @user_data.trains[train.number] = train
    puts "New cargo train created. Its number is: #{train.number}"
  end

  def create_passenger_train(train_number = nil)
    train = PassengerTrain.new(train_number)
    @user_data.trains[train.number] = train
    puts "New passenger train created. Its number is: #{train.number}"
  end

  def show_existing_trains
    if !@user_data.trains.empty?
      display_trains('passenger')
      display_trains('cargo')
    else
      puts 'There are no trains.'
    end
  end

  def create_route(first_station, last_station, route_number = nil)
    check_station_existence(first_station)
    check_station_existence(last_station)
    route = if route_number && !route_number.empty?
              Route.new(first_station, last_station, route_number)
            else
              Route.new(first_station, last_station)
            end
    @user_data.routes[route.number] = route
    puts "Route '#{route.number}' created"
  end

  def add_station_to_route(route_name, station_name)
    check_route_existence(route_name)
    check_station_existence(station_name)
    @user_data.routes[route_name].add_station(station_name)
    puts "Station #{station_name} were added to route #{route_name}"
  end

  def remove_station_from_route(route_name, station_name)
    check_route_existence(route_name)
    check_station_existence(station_name)
    @user_data.routes[route_name].delete_station(station_name)
    puts "Station '#{station_name}' were removed from route '#{route_name}'"
  end

  def add_route_to_train(route_name, train_number)
    check_route_existence(route_name)
    check_train_existence(train_number)
    register_route_at_train(route_name, train_number)
    register_train_at_station(train_number)
  end

  def add_carriage_to_train(train_number)
    check_train_existence(train_number)
    type = @user_data.trains[train_number].type
    is_cargo = type == 'cargo'
    carriage = is_cargo ? create_cargo_carriage : create_passenger_carriage
    @user_data.trains[train_number].add_carriage(carriage)
    puts "#{type.capitalize} carriage was added to train '#{train_number}'"
  end

  def remove_carriage_from_train(train_number, carriage_number)
    check_train_existence(train_number)
    check_train_has_such_carriage(train_number, carriage_number)
    @user_data.trains[train_number].remove_carriage(carriage_number)
    puts "'#{carriage_number}' was removed from train '#{train_number}'"
  end

  def move_train_forward(train_number)
    check_train_existence(train_number)
    unregister_train_at_station(train_number)
    @user_data.trains[train_number].move_forward
    register_train_at_station(train_number)
    message = 'Train had arrived at next station! Current station is '
    puts message + @user_data.trains[train_number].current_station.to_s
  end

  def move_train_backward(train_number)
    check_train_existence(train_number)
    unregister_train_at_station(train_number)
    @user_data.trains[train_number].move_backward
    register_train_at_station(train_number)
    message = 'Train had arrived at previous station! Current station is '
    puts message + @user_data.trains[train_number].current_station.to_s
  end

  def show_trains_at_station(station_name)
    check_station_existence(station_name)
    puts "There are next trains at station '#{station_name}':"
    show_train = proc { |train| puts train_description(train) }
    station = @user_data.stations[station_name]
    station.each_train { |train| show_train.call train }
  end

  def show_carriages_of_train(train_number)
    show_cargo = proc { |carriage| puts "Number: #{carriage.number}, Type: #{carriage.type}, Empty cargo: #{carriage.free_volume}, Occupied cargo: #{carriage.occupied_volume}" }
    show_passenger = proc { |carriage| puts "Number: #{carriage.number}, Type: #{carriage.type}, Free seats: #{carriage.free_seats}, Taken seats: #{carriage.taken_seats}" }
    train = @user_data.trains[train_number]
    train.each_carriage { |carriage| carriage.type == 'cargo' ? show_cargo.call(carriage) : show_passenger.call(carriage) }
  end

  def take_seat_in_carriage(carriage_number)
    check_carriage_existence(carriage_number)
    check_carriage_is_passenger(carriage_number)
    carriage = Carriage.carriages.select { |carriage| carriage.number == carriage_number }[0]
    carriage.take_seat
    puts "One more place taken in carriage #{carriage_number}"
  end

  def place_cargo_in_carriage(carriage_number, cargo_volume)
    check_carriage_existence(carriage_number)
    check_carriage_is_cargo(carriage_number)
    carriage = Carriage.carriages.select { |carriage| carriage.number == carriage_number }[0]
    carriage.place_cargo cargo_volume.to_i
    puts "Cargo (#{cargo_volume}) placed in carriage #{carriage_number}"
  end

  private

  def train_description(train)
    number = "Number: #{train.number}"
    type = "Type: #{train.type}"
    carriages = "Carriages: #{train.number_of_carriages}"
    [number, type, carriages].join(', ')
  end

  def unregister_train_at_station(train_number)
    current_station = @user_data.trains[train_number].current_station
    @user_data.stations[current_station].send_train(train_number)
  end

  def register_route_at_train(route_name, train_number)
    @user_data.trains[train_number].define_route(@user_data.routes[route_name])
    puts "Train '#{train_number}' is following route '#{route_name}' now"
  end

  def register_train_at_station(train_number)
    station_name = @user_data.trains[train_number].current_station
    @user_data.stations[station_name].train_arrived(@user_data.trains[train_number])
  end

  def display_trains(type)
    p_trains = @user_data.trains.select { |_, train| train.type == type }
    p_trains = p_trains.map(&method(:train_to_str))
    puts "There are next #{type} trains: " + p_trains.compact.join(',')
  end

  def train_to_str(name, train)
    name + '(' + train.carriages.map(&:number).join(',') + ')'
  end

  def check_route_existence(route_name)
    unless @user_data.routes.keys.include? route_name
      raise RailwayError, "No such route #{route_name}"
    end
  end

  def check_station_existence(station_name)
    unless @user_data.stations.keys.include? station_name
      raise RailwayError, "No such station #{station_name}"
    end
  end

  def check_train_existence(train_name)
    unless @user_data.trains.keys.include? train_name
      raise RailwayError, "No such train #{train_name}"
    end
  end

  def check_train_has_such_carriage(train_number, carriage_number)
    error_message = "Train '#{train_number}' has no carriages with number '#{carriage_number}'"
    has_carriage = @user_data.trains[train_number].carriages.map(&:number).include?(carriage_number)
    raise RailwayError, error_message unless has_carriage
  end

  def create_cargo_carriage
    max_cargo_volume = get_request_parameters [%i[req max_cargo_volumne]]
    CargoCarriage.new(*max_cargo_volume)
  end

  def create_passenger_carriage
    number_of_seats = get_request_parameters [%i[req number_of_seats]]
    PassengerCarriage.new(*number_of_seats)
  end

  def check_carriage_existence(carriage_number)
    error_message = "There is no carriage with number '#{carriage_number}'!"
    carriage_exists = Carriage.carriages.map(&:number).include? carriage_number
    raise RailwayError, error_message unless carriage_exists
  end

  def check_carriage_is_passenger(number)
    carriage = Carriage.carriages.select { |carriage| carriage.number == number }[0]
    error_message = 'Can`t add seats to cargo carriage!'
    raise RailwayError, error_message unless carriage.is_a? PassengerCarriage
  end

  def check_carriage_is_cargo(number)
    carriage = Carriage.carriages.select { |carriage| carriage.number == number }[0]
    error_message = 'Can`t add goods to passenger carriage!'
    raise RailwayError, error_message unless carriage.is_a? CargoCarriage
  end
end

class UserData
  attr_accessor :stations, :trains, :routes
  def initialize
    @stations = {}
    @trains = {}
    @routes = {}
  end
end

if $PROGRAM_NAME == __FILE__
  user_interface = UserInterface.new
  user_interface.create_default_menu
  user_interface.main_loop
end
