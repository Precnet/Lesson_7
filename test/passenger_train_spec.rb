require 'rspec'
require_relative '../passenger_train.rb'

describe 'PassengerTrain' do
  it 'should create train subclass of type passenger' do
    train = PassengerTrain.new('12345')
    expect(train.type).to eq('passenger')
    expect(train.type).not_to eq('cargo')
    expect(train.type).not_to eq('12345')
    expect(train.class).to eq(PassengerTrain)
    expect(train.carriages.length).to eq(0)
  end

  context 'Carriage manipulations' do
    before(:all) do
      @train = PassengerTrain.new('54321')
    end
    it 'should add new carriages' do
      carriage1 = PassengerCarriage.new('carriage 1', 20)
      carriage2 = PassengerCarriage.new('carriage 2', 22)
      wrong_carriage = double('CargoCarriage', type: 'cargo')
      @train.add_carriage(carriage1)
      expect(@train.carriages.length).to eq(1)
      @train.add_carriage(carriage2)
      expect(@train.carriages.length).to eq(2)
      expect { @train.add_carriage('passenger') }.to raise_error(ArgumentError)
      expect { @train.add_carriage(wrong_carriage) }.to raise_error(ArgumentError)
      @train.increase_speed_by(10)
      expect { @train.add_carriage('passenger') }.to raise_error(RuntimeError)
    end
  end
end
