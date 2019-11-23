require 'rspec'
require_relative '../cargo_carriage.rb'

describe 'CargoCarriage' do
  before(:all) do
    @carriage = CargoCarriage.new(10)
  end
  it 'should create cargo carriage' do
    expect(@carriage.type).to eq('cargo')
  end
  it 'should have manufacturer name' do
    @carriage.manufacturer = 'Train inc.'
    expect(@carriage.manufacturer).to eq('Train inc.')
  end
  it 'should create carriages with fixed number' do
    carriage2 = CargoCarriage.new('1234', 10)
    expect(carriage2.number).to eq('1234')
  end
end