require 'rspec'
require_relative '../cargo_train.rb'
require_relative '../passenger_carriage.rb'
require_relative '../cargo_carriage.rb'

describe 'CargoTrain' do
  it 'should create train subclass of type cargo' do
    train = CargoTrain.new('12345')
    expect(train.type).to eq('cargo')
    expect(train.type).not_to eq('passenger')
    expect(train.type).not_to eq('12345')
    expect(train.class).to eq(CargoTrain)
    expect(train.carriages.length).to eq(0)
  end

  context 'Carriage manipulations' do
    before(:all) do
      @train = CargoTrain.new('12345')
    end
    it 'should add new carriages' do
      carriage1 = CargoCarriage.new(10, 'carriage 1')
      carriage2 = CargoCarriage.new(10, 'carriage 2')
      wrong_carriage = PassengerCarriage.new('PassengerCarriage', 10)
      @train.add_carriage(carriage1)
      expect(@train.carriages.length).to eq(1)
      @train.add_carriage(carriage2)
      expect(@train.carriages.length).to eq(2)
      expect { @train.add_carriage('cargo') }.to raise_error(ArgumentError)
      expect { @train.add_carriage(wrong_carriage) }.to raise_error(ArgumentError)
      @train.increase_speed_by(10)
      expect { @train.add_carriage('cargo') }.to raise_error(RuntimeError)
    end
    it 'should apply custom block to each carriage' do
      # puts carriage`s types
      types = "cargo\ncargo\n"
      expect { @train.each_carriage { |carriage| puts carriage.type } }.to output(types).to_stdout
      # place 2 cargo in each carriage
      free_cargo = "8\n8\n"
      @train.each_carriage { |carriage| carriage.place_cargo(2) }
      expect { @train.each_carriage { |carriage| puts carriage.free_volume }}.to output(free_cargo).to_stdout
    end
  end
end
