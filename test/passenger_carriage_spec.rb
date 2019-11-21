require 'rspec'
require_relative '../passenger_carriage.rb'

describe 'PassengerCarriage' do
  before(:all) do
    @carriage = PassengerCarriage.new(10)
    @carriage2 = PassengerCarriage.new('1234', 30)
  end
  it 'should create passenger carriage' do
    expect(@carriage.type).to eq('passenger')
  end
  it 'should have manufacturer name' do
    @carriage.manufacturer = 'Train inc.'
    expect(@carriage.manufacturer).to eq('Train inc.')
  end
  it 'should create carriages with fixed number' do
    expect(@carriage2.number).to eq('1234')
  end
  it 'should create carriages with specifies number of seats' do
    expect(@carriage.instance_variable_get(:@num_of_seats)).to eq(10)
    expect(@carriage2.instance_variable_get(:@num_of_seats)).to eq(30)
  end
end