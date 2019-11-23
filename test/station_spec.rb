require 'rspec'
require_relative '../station.rb'
require_relative '../train.rb'

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
      @train_1 = Train.new('cargo', 10, '001-01')
      @train_2 = Train.new('passenger', 15, '002-02')
      @train_3 = Train.new('cargo', 8, '003-03')
    end
    it 'should send trains by one' do
      @station.train_arrived(@train_1)
      @station.train_arrived(@train_2)
      @station.train_arrived(@train_3)
      @station.send_train('001-01')
      expect(@station.trains_at_station.length).to eq(2)
      expect { @station.send_train('004') }.to raise_error(ArgumentError)
      @station.send_train('002-02')
      @station.send_train('003-03')
      expect(@station.trains_at_station.length).to eq(0)
      expect { @station.send_train('some_value') }.to raise_error(ArgumentError)
    end
    it 'should add trains to station one by one' do
      @station.train_arrived(@train_1)
      expect(@station.trains_at_station.length).to eq(1)
      @station.train_arrived(@train_2)
      @station.train_arrived(@train_3)
      expect(@station.trains_at_station.length).to eq(3)
      expect(@station.trains_at_station[1].type).to eq('passenger')
      # cleaning up
      @station.send_train('001-01')
      @station.send_train('002-02')
      @station.send_train('003-03')
    end
    it 'should return trains currently at station' do
      @station.train_arrived(@train_1)
      @station.train_arrived(@train_2)
      @station.train_arrived(@train_3)
      expect(@station.trains_at_station).to eq([@train_1, @train_2, @train_3])
      @station.send_train('001-01')
      @station.send_train('002-02')
      @station.send_train('003-03')
      expect(@station.trains_at_station).to eq([])
    end
    it 'should display trains of type' do
      @station.train_arrived(@train_1)
      @station.train_arrived(@train_2)
      @station.train_arrived(@train_3)
      expect(@station.trains_at_station_of_type('cargo')).to eq(%w[001-01 003-03])
      expect(@station.trains_at_station_of_type('passenger')).to eq(%w[002-02])
      expect(@station.trains_at_station_of_type('some other train type')).to eq([])
      @station.send_train('001-01')
      @station.send_train('002-02')
      @station.send_train('003-03')
    end
    it 'should display trains by type' do
      @station.train_arrived(@train_1)
      @station.train_arrived(@train_2)
      @station.train_arrived(@train_3)
      expect(@station.trains_at_station_by_type).to eq({"cargo"=>2, "passenger"=>1})
      @station.send_train('002-02')
      expect(@station.trains_at_station_by_type).to eq({"cargo"=>2})
      @station.send_train('001-01')
      expect(@station.trains_at_station_by_type).to eq({"cargo"=>1})
      @station.train_arrived(@train_2)
      expect(@station.trains_at_station_by_type).to eq({"cargo"=>1, "passenger"=>1})
      @station.send_train('002-02')
      @station.send_train('003-03')
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
    it 'should apply custom block to trains on station' do
      @station.train_arrived(@train_1)
      @station.train_arrived(@train_2)
      @station.train_arrived(@train_3)

      # puts trains`s types
      types = "cargo\npassenger\ncargo\n"
      expect { @station.process_trains { |train| puts train.type } }.to output(types).to_stdout
      # increase speed of cargo trains and puts it
      speeds = "10\n10\n"
      expect { @station.process_trains { |train| puts train.increase_speed_by(10) if train.type == 'cargo' }}.to output(speeds).to_stdout

      expect { @station.process_trains }.to raise_error(RailwayError)
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
