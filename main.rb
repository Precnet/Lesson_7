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
    while true
      show_menu
      process_user_input get_user_input
    end
  end

  def create_menu_item(item, command)
    @menu_items[item] = command
  end

  def show_menu
    puts '--- Main menu ---'
    @menu_items.each_with_index {|item, index| puts((index + 1).to_s + ' - ' + item.to_s.capitalize.gsub('_', ' ')) }
    puts '______ End ______'
    puts
  end

  def select_menu_item(item, args=nil)
    raise ArgumentError, "No such menu item: #{item}!" unless @menu_items.include?(item)
    args ? @user_action.send(item, *args) : @user_action.send(item)
  end

  private

  # these methods should not be called outside of class methods
  def get_user_input
    print 'Type index number to select menu item: '
    gets.strip
  end

  def process_user_input(user_input)
    user_input = user_input.to_i
    error_message = 'There is no such menu item!'
    raise ArgumentError, error_message unless (1..@menu_items.length).include? user_input
    begin
      parameters = get_request_parameters @user_action.method(@menu_items[user_input - 1]).parameters
      select_menu_item(@menu_items[user_input - 1], parameters)
    rescue
      puts $!.message
      retry
    end
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
      puts @user_data.stations.keys{ |station_name| station_name }.join(', ')
    else
      puts 'There are no stations.'
    end
  end

  def create_cargo_train(train_number=nil)
    train = CargoTrain.new(train_number)
    @user_data.trains[train.number] = train
    puts "New cargo train created. Its number is: #{train.number}"
  end

  def create_passenger_train(train_number=nil)
    train = PassengerTrain.new(train_number)
    @user_data.trains[train.number] = train
    puts "New passenger train created. Its number is: #{train.number}"
  end

  def show_existing_trains
    if !@user_data.trains.empty?
      passenger_trains = @user_data.trains.select { |_, train| train.type == 'passenger'}
      passenger_trains = passenger_trains.map {|name, train| name + '(' + train.carriages.map{|carriage| carriage.number}.join(',') + ')'}
      puts 'There are next passenger trains: ' + passenger_trains.compact.join(',')
      cargo_trains = @user_data.trains.select { |_, train| train.type == 'cargo'}
      cargo_trains = cargo_trains.map {|name, train| name + '(' + train.carriages.map{|carriage| carriage.number}.join(',') + ')'}
      puts 'There are next cargo trains: ' + cargo_trains.compact.join(',')
    else
      puts 'There are no trains.'
    end
  end

  def create_route(first_station, last_station, route_number=nil)
    no_such_station_message = 'There are no station with such name.'
    stations_exist = @user_data.stations.keys.include?(first_station) && @user_data.stations.keys.include?(last_station)
    raise ArgumentError, no_such_station_message unless stations_exist
    if route_number && !route_number.empty?
      route = Route.new(first_station, last_station, route_number)
    else
      route = Route.new(first_station, last_station)
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
    # register route and set current station as first station
    @user_data.trains[train_number].define_route(@user_data.routes[route_name])
    # register train at station
    station_name = @user_data.trains[train_number].current_station
    @user_data.stations[station_name].train_arrived(@user_data.trains[train_number])
    puts "Train '#{train_number}' is following route '#{route_name}' now"
  end

  def add_carriage_to_train(train_number)
    check_train_existence(train_number)
    type = @user_data.trains[train_number].type
    carriage = type == 'cargo' ? create_cargo_carriage : create_passenger_carriage
    @user_data.trains[train_number].add_carriage(carriage)
    puts "#{type.capitalize} carriage was added to train '#{train_number}'"
  end

  def remove_carriage_from_train(train_number, carriage_number)
    check_train_existence(train_number)
    check_train_has_such_carriage(train_number, carriage_number)
    @user_data.trains[train_number].remove_carriage(carriage_number)
    puts "Carriage '#{carriage_number}' was removed from train '#{train_number}'"
  end

  def move_train_forward(train_number)
    check_train_existence(train_number)
    # current station: unregister train
    current_station = @user_data.trains[train_number].current_station
    @user_data.stations[current_station].send_train(train_number)
    # train: move to next station
    @user_data.trains[train_number].move_forward
    # new station: register train
    new_station = @user_data.trains[train_number].current_station
    @user_data.stations[new_station].train_arrived(@user_data.trains[train_number])
    message = 'Train had arrived at next station! Current station is '
    puts message + "#{@user_data.trains[train_number].current_station}"
  end

  def move_train_backward(train_number)
    check_train_existence(train_number)
    # current station: unregister train
    current_station = @user_data.trains[train_number].current_station
    @user_data.stations[current_station].send_train(train_number)
    # train: move to previous station
    @user_data.trains[train_number].move_backward
    # new station: register train
    new_station = @user_data.trains[train_number].current_station
    @user_data.stations[new_station].train_arrived(@user_data.trains[train_number])
    message = 'Train had arrived at previous station! Current station is '
    puts message + "#{@user_data.trains[train_number].current_station}"
  end

  def show_trains_at_station(station_name)
    check_station_existence(station_name)
    puts "There are next trains at station '#{station_name}':"
    # puts "Passenger trains: #{@user_data.stations[station_name].trains_at_station_of_type('passenger')}"
    # puts "Cargo trains: #{@user_data.stations[station_name].trains_at_station_of_type('cargo')}"
    show_train = Proc.new { |train| puts "Number: #{train.number}, Type: #{train.type}, Carriages: #{train.number_of_carriages}" }
    station = @user_data.stations[station_name]
    station.each_train { |train| show_train.call train }
  end

  def show_carriages_of_train(train_number)
    show_cargo = Proc.new { |carriage| puts "Number: #{carriage.number}, Type: #{carriage.type}, Empty cargo: #{carriage.free_volume}, Occupied cargo: #{carriage.occupied_volume}" }
    show_passenger = Proc.new { |carriage| puts "Number: #{carriage.number}, Type: #{carriage.type}, Free seats: #{carriage.free_seats}, Taken seats: #{carriage.taken_seats}" }
    train = @user_data.trains[train_number]
    train.each_carriage { |carriage| carriage.type == 'cargo' ? show_cargo.call(carriage) : show_passenger.call(carriage) }
  end

  def take_seat_in_carriage(carriage_number)
    check_carriage_existence(carriage_number)
    check_carriage_is_passenger(carriage_number)
    carriage = Carriage.carriages.select { |carriage| carriage.number == carriage_number }
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

  def check_route_existence(route_name)
    raise RailwayError, "No such route #{route_name}" unless @user_data.routes.keys.include? route_name
  end

  def check_station_existence(station_name)
    raise RailwayError, "No such station #{station_name}" unless @user_data.stations.keys.include? station_name
  end

  def check_train_existence(train_name)
    raise RailwayError, "No such train #{train_name}" unless @user_data.trains.keys.include? train_name
  end

  def check_train_has_such_carriage(train_number, carriage_number)
    error_message = "Train '#{train_number}' has no carriages with number '#{carriage_number}'"
    has_carriage = @user_data.trains[train_number].carriages.map{|carriage| carriage.number}.include?(carriage_number)
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
    carriage_exists = Carriage.carriages.map { |carriage| carriage.number }.include? carriage_number
    raise RailwayError, error_message unless carriage_exists
  end

  def check_carriage_is_passenger(carriage_number)
    carriage = Carriage.carriages.select { |carriage| carriage.number == carriage_number }[0]
    error_message = 'Can`t add seats to cargo carriage!'
    raise RailwayError, error_message unless carriage.is_a? PassengerCarriage
  end

  def check_carriage_is_cargo(carriage_number)
    carriage = Carriage.carriages.select { |carriage| carriage.number == carriage_number }[0]
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


if __FILE__==$0
  user_interface = UserInterface.new
  user_interface.create_default_menu
  user_interface.main_loop
end
