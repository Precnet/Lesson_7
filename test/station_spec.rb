require 'rspec'
require_relative '../station.rb'

describe 'Station' do
  it 'should create station with custom name' do
    station = Station.new('first_station_ever')
    expect(station.name).to eq('first_station_ever')
  end
  it 'shouldn`t create station with incorrect name' do
    expect { Station.new(nil) }.to raise_error(RailwayError)
    expect { Station.new(342) }.to raise_error(RailwayError)
    expect { Station.new(['good_station_name']) }.to raise_error(RailwayError)
    expect { Station.new('') }.to raise_error(RailwayError)
    expect { Station.new('very-very-very long station name') }.to raise_error(RailwayError)
  end
  context 'trains manipulations' do
    before(:all) do
      @station = Station.new('some_station')
    end
    it 'should send trains by one' do
      train_1 = double('Train', type: 'cargo', number: '001')
      train_2 = double('Train', type: 'passenger', number: '002')
      train_3 = double('Train', type: 'cargo', number: '003')
      @station.train_arrived(train_1)
      @station.train_arrived(train_2)
      @station.train_arrived(train_3)
      @station.send_train('001')
      expect(@station.trains_at_station.length).to eq(2)
      expect { @station.send_train('004') }.to raise_error(ArgumentError)
      @station.send_train('002')
      @station.send_train('003')
      expect(@station.trains_at_station.length).to eq(0)
      expect { @station.send_train('some_value') }.to raise_error(ArgumentError)
    end
    it 'should add trains to station one by one' do
      train_1 = double('Train', type: 'cargo', number: '001')
      train_2 = double('Train', type: 'passenger', number: '002')
      train_3 = double('Train', type: 'cargo', number: '003')
      @station.train_arrived(train_1)
      expect(@station.trains_at_station.length).to eq(1)
      @station.train_arrived(train_2)
      @station.train_arrived(train_3)
      expect(@station.trains_at_station.length).to eq(3)
      expect(@station.trains_at_station[1].type).to eq('passenger')
      # cleaning up
      @station.send_train('001')
      @station.send_train('002')
      @station.send_train('003')
    end
    it 'should return trains currently at station' do
      train_1 = double('Train', type: 'cargo', number: '001')
      train_2 = double('Train', type: 'passenger', number: '002')
      train_3 = double('Train', type: 'cargo', number: '003')
      @station.train_arrived(train_1)
      @station.train_arrived(train_2)
      @station.train_arrived(train_3)
      expect(@station.trains_at_station).to eq([train_1, train_2, train_3])
      @station.send_train('001')
      @station.send_train('002')
      @station.send_train('003')
      expect(@station.trains_at_station).to eq([])
    end
    it 'should display trains of type' do
      train_1 = double('Train', type: 'cargo', number: '001')
      train_2 = double('Train', type: 'passenger', number: '002')
      train_3 = double('Train', type: 'cargo', number: '003')
      @station.train_arrived(train_1)
      @station.train_arrived(train_2)
      @station.train_arrived(train_3)
      expect(@station.trains_at_station_of_type('cargo')).to eq(%w[001 003])
      expect(@station.trains_at_station_of_type('passenger')).to eq(%w[002])
      expect(@station.trains_at_station_of_type('some other train type')).to eq([])
      @station.send_train('001')
      @station.send_train('002')
      @station.send_train('003')
    end
    it 'should display trains by type' do
      train_1 = double('Train', type: 'cargo', number: '001')
      train_2 = double('Train', type: 'passenger', number: '002')
      train_3 = double('Train', type: 'cargo', number: '003')
      @station.train_arrived(train_1)
      @station.train_arrived(train_2)
      @station.train_arrived(train_3)
      expect(@station.trains_at_station_by_type).to eq({"cargo"=>2, "passenger"=>1})
      @station.send_train('002')
      expect(@station.trains_at_station_by_type).to eq({"cargo"=>2})
      @station.send_train('001')
      expect(@station.trains_at_station_by_type).to eq({"cargo"=>1})
      @station.train_arrived(train_2)
      expect(@station.trains_at_station_by_type).to eq({"cargo"=>1, "passenger"=>1})
      @station.send_train('002')
      @station.send_train('003')
      expect(@station.trains_at_station_by_type).to eq({})
    end
    it 'should return all instances instances' do
      expect(Station.all.length).to eq(11)
      expect(Station.all.select { |station| station.class == Station }.length).to eq(11)
    end
    it 'should count instances via mixin' do
      expect(Station.number_of_instances).to eq(11)
      Station.new('1234')
      expect(Station.number_of_instances).to eq(12)
    end
  end
  context 'checking validness of object' do
    before(:each) do
      @station = Station.new('Exception')
    end
    it 'should raise error with nil station name' do
      expect(@station.valid?).to eq(true)
      @station.instance_variable_set(:@name, nil)
      expect(@station.valid?).to eq(false)
    end
    it 'should raise error with zero length station name' do
      expect(@station.valid?).to eq(true)
      @station.instance_variable_set(:@name, '')
      expect(@station.valid?).to eq(false)
    end
    it 'should raise error with non-string station name' do
      expect(@station.valid?).to eq(true)
      @station.instance_variable_set(:@name, 12345)
      expect(@station.valid?).to eq(false)
    end
    it 'should raise error with too long station name' do
      expect(@station.valid?).to eq(true)
      @station.instance_variable_set(:@name, 'azsldkhfaklshfkashfakshfkashdfka')
      expect(@station.valid?).to eq(false)
    end
  end
end
