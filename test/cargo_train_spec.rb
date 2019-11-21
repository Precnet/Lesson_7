require 'rspec'
require_relative '../cargo_train.rb'

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
      carriage = double('CargoCarriage', type: 'cargo')
      wrong_carriage = double('PassengerCarriage', type: 'passenger')
      @train.add_carriage(carriage)
      expect(@train.carriages.length).to eq(1)
      @train.add_carriage(carriage)
      expect(@train.carriages.length).to eq(2)
      expect { @train.add_carriage('cargo') }.to raise_error(ArgumentError)
      expect { @train.add_carriage(wrong_carriage) }.to raise_error(ArgumentError)
      @train.increase_speed_by(10)
      expect { @train.add_carriage('cargo') }.to raise_error(RuntimeError)
    end
  end
end
