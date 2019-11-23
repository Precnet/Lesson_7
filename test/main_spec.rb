require 'rspec'
require_relative '../main.rb'

describe 'UserInterface' do
  before(:all) do
    @ui = UserInterface.new
  end
  context 'creating menu' do
    it 'should auto create menu' do
      @ui.create_default_menu
      menu = [:add_carriage_to_train, :add_route_to_train, :add_station_to_route, :create_cargo_train,
              :create_passenger_train, :create_route, :create_station, :move_train_backward, :move_train_forward,
              :remove_carriage_from_train, :remove_station_from_route, :show_existing_stations, :show_existing_trains,
              :show_trains_at_station]
      expect(@ui.menu_items).to eq(menu)
    end
  end
  context 'creating and selecting new menu items' do
    it 'should show all created stations' do
      message_1 = "There are no stations.\n"
      expect { @ui.select_menu_item(:show_existing_stations) }.to output(message_1).to_stdout
      @ui.select_menu_item(:create_station, 'one')
      message_2 = "There are next stations:\none\n"
      expect { @ui.select_menu_item(:show_existing_stations) }.to output(message_2).to_stdout
      @ui.select_menu_item(:create_station, 'two')
      @ui.select_menu_item(:create_station, 'three')
      message_3 = "There are next stations:\none, two, three\n"
      expect { @ui.select_menu_item(:show_existing_stations) }.to output(message_3).to_stdout
    end
    it 'should add new stations' do
      message = "Created station: test\n"
      expect { @ui.select_menu_item(:create_station, 'test') }.to output(message).to_stdout
    end
    it 'should create new trains' do
      expect { @ui.select_menu_item(:show_existing_trains) }.to output("There are no trains.\n").to_stdout
      message_1 = "New passenger train created. Its number is: test1\n"
      expect { @ui.select_menu_item(:create_passenger_train, 'test1') }.to output(message_1).to_stdout
      message_2 = "New cargo train created. Its number is: 123-45\n"
      expect { @ui.select_menu_item(:create_cargo_train, '123-45') }.to output(message_2).to_stdout
      @ui.select_menu_item(:create_cargo_train, '54321')
      @ui.select_menu_item(:show_existing_trains)
      message_3 = "There are next passenger trains: test1()\nThere are next cargo trains: 123-45(),54321()\n"
      expect { @ui.select_menu_item(:show_existing_trains) }.to output(message_3).to_stdout
    end
  end
  context 'route management' do
    it 'should create new routes' do
      @ui.select_menu_item(:create_station, 'first')
      @ui.select_menu_item(:create_station, 'last')
      message = "Route 'test' created\n"
      expect { @ui.select_menu_item(:create_route, ['first', 'last', 'test']) }.to output(message).to_stdout
      expect(@ui.user_data.routes.length).to eq(1)
      @ui.select_menu_item(:create_route, ['last', 'first'])
      expect(@ui.user_data.routes.length).to eq(2)
    end
    it 'should add stations to routes' do
      @ui.select_menu_item(:create_station, 'new_1')
      route_name = @ui.user_data.routes.keys.first
      station_name = @ui.user_data.stations.keys.last
      expect { @ui.select_menu_item(:add_station_to_route, [route_name, 'new_1']).to raise_error(ArgumentError) }
      expect { @ui.select_menu_item(:add_station_to_route, ['some_route', station_name]).to raise_error(ArgumentError) }
      message = "Station #{station_name} were added to route #{route_name}\n"
      expect { @ui.select_menu_item(:add_station_to_route, [route_name, station_name]) }.to output(message).to_stdout
      expect(@ui.user_data.routes[route_name].stations.length).to eq(3)
      expect(@ui.user_data.routes[route_name].stations[-2]).to eq('new_1')
    end
    it 'should delete stations from route' do
      @ui.select_menu_item(:create_station, 'middle_1')
      @ui.select_menu_item(:create_station, 'middle_2')
      route_name = @ui.user_data.routes.keys.first
      @ui.select_menu_item(:add_station_to_route, [route_name, 'middle_1'])
      @ui.select_menu_item(:add_station_to_route, [route_name, 'middle_2'])
      expect(@ui.user_data.routes[route_name].stations.length).to eq(5)
      expect { @ui.select_menu_item(:remove_station_from_route, [route_name, 'new_2']) }.to raise_error(ArgumentError)
      expect { @ui.select_menu_item(:remove_station_from_route, ['route_name', 'new_1']) }.to raise_error(ArgumentError)
      message = "Station 'new_1' were removed from route '#{route_name}'\n"
      expect { @ui.select_menu_item(:remove_station_from_route, [route_name, 'new_1']) }.to output(message).to_stdout
      expect(@ui.user_data.routes[route_name].stations.length).to eq(4)
      @ui.select_menu_item(:remove_station_from_route, [route_name, 'middle_1'])
      @ui.select_menu_item(:remove_station_from_route, [route_name, 'middle_2'])
      expect(@ui.user_data.routes[route_name].stations.length).to eq(2)
    end
    it 'should add route to train' do
      # @ui.create_menu_item(:create_passenger_train, -> (number=nil) { @ua.create_passenger_train number})
      @ui.select_menu_item(:create_passenger_train, 'train')
      route_name = @ui.user_data.routes.keys.first
      train_name = @ui.user_data.trains.keys.first
      expect { @ui.select_menu_item(:add_route_to_train, [route_name, 'some_train']) }.to raise_error(ArgumentError)
      message = "Train '#{train_name}' is following route '#{route_name}' now\n"
      expect { @ui.select_menu_item(:add_route_to_train, [route_name, train_name]) }.to output(message).to_stdout
    end
  end
  context 'carriage management' do
    it 'should add carriage to train' do
      message_passenger = "Enter number of seats: Passenger carriage was added to train 'test1'\n"
      expect(@ui.user_data.trains['test1'].number_of_carriages).to eq(0)
      allow_any_instance_of(Kernel).to receive(:gets).and_return('10')
      expect { @ui.select_menu_item(:add_carriage_to_train, 'test1') }.to output(message_passenger).to_stdout
      expect(@ui.user_data.trains['test1'].number_of_carriages).to eq(1)
      expect { @ui.select_menu_item(:add_carriage_to_train, 'test1') }.to output(message_passenger).to_stdout
      message_cargo = "Enter max cargo volumne: Cargo carriage was added to train '123-45'\n"
      expect { @ui.select_menu_item(:add_carriage_to_train, '123-45') }.to output(message_cargo).to_stdout
    end
    it 'should remove carriage from train' do
      expect { @ui.select_menu_item(:remove_carriage_from_train, ['test', 'smth']) }.to raise_error(ArgumentError)
      carriage_number = @ui.user_data.trains['test1'].carriages[0].number
      message = "Carriage '#{carriage_number}' was removed from train 'test1'\n"
      expect(@ui.user_data.trains['test1'].number_of_carriages).to eq(2)
      expect { @ui.select_menu_item(:remove_carriage_from_train, ['test1', carriage_number]) }.to output(message).to_stdout
      expect(@ui.user_data.trains['test1'].number_of_carriages).to eq(1)
    end
  end
  context 'train movement' do
    it 'should move train forward and backward' do
      message_forward = "Train had arrived at next station! Current station is last\n"
      expect { @ui.select_menu_item(:move_train_forward, 'test1') }.to output(message_forward).to_stdout
      route_name = @ui.user_data.trains['test1'].route.number
      @ui.select_menu_item(:add_station_to_route, [route_name, 'middle_1'])
      message_backward = "Train had arrived at previous station! Current station is middle_1\n"
      expect { @ui.select_menu_item(:move_train_backward, 'test1') }.to output(message_backward).to_stdout
    end
  end
  context 'displaying trains at station' do
    it 'should correctly display trains at station' do
      message_1 = "There are next trains at station 'middle_1':\nPassenger trains: [\"test1\"]\nCargo trains: []\n"
      expect { @ui.select_menu_item(:show_trains_at_station, 'middle_1') }.to output(message_1).to_stdout
      @ui.select_menu_item(:move_train_forward, 'test1')
      message_2 = "There are next trains at station 'middle_1':\nPassenger trains: []\nCargo trains: []\n"
      expect { @ui.select_menu_item(:show_trains_at_station, 'middle_1') }.to output(message_2).to_stdout
      @ui.select_menu_item(:move_train_backward, 'test1')
      expect { @ui.select_menu_item(:show_trains_at_station, 'middle_1') }.to output(message_1).to_stdout
    end
  end
end
