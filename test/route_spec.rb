require 'rspec'
require_relative '../route.rb'

describe 'Route' do
  before(:all) do
    @route = Route.new('first', 'last')
  end
  it 'should take two arguments and constructs array of initial stations' do
    expect(@route.stations.length).to eq(2)
    expect(@route.stations[0]).to eq('first')
    expect(@route.stations[1]).to eq('last')
  end
  it 'should add intermediate station to route' do
    @route.add_station('new_station')
    expect(@route.stations[1]).to eq('new_station')
    expect(@route.stations.length).to eq(3)
  end
  it 'should delete station from route if there is such a station' do
    @route.add_station('wrong_station')
    expect(@route.stations.length).to eq(4)
    expect(@route.stations[-2]).to eq('wrong_station')
    @route.delete_station('wrong_station')
    expect(@route.stations.length).to eq(3)
    expect(@route.stations[-2]).to eq('new_station')
    expect { @route.delete_station('one_more_wrong_station') }.to raise_error(ArgumentError)
  end
  it 'should create route name of use one of users choice' do
    route_2 = Route.new('one', 'two', '12345')
    route_3 = Route.new('one', 'two')
    expect(route_2.number).to eq('12345')
    expect(route_2.number).not_to eq(@route.number)
    expect(route_3.number).not_to eq(@route.number)
  end
  it 'should count instances via mixin' do
    expect(Route.number_of_instances).to eq(5)
    Route.new('first', 'last')
    expect(Route.number_of_instances).to eq(6)
  end
end
