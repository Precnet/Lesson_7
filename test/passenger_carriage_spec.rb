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
    expect(@carriage.number_of_seats).to eq(10)
    expect(@carriage2.number_of_seats).to eq(30)
  end
  it 'should increase number of taken seats by one' do
    @carriage.take_seat
    expect(@carriage.taken_seats).to eq(1)
    expect(@carriage.free_seats).to eq(9)
    @carriage2.take_seat
    @carriage2.take_seat
    expect(@carriage2.taken_seats).to eq(2)
    expect(@carriage2.free_seats).to eq(28)
  end
  it 'shouldn`t take seats if there are no free seats' do
    carriage3 = PassengerCarriage.new(1)
    carriage3.take_seat
    expect { carriage3.take_seat }.to raise_error(RailwayError)
  end
end