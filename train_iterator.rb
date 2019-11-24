require_relative 'railway_error.rb'

module TrainIterator
  def each_train
    no_block_error = 'This method requires block to operate!'
    raise RailwayError, no_block_error unless block_given?

    @carriages.each{ |carriage| yield carriage }
  end
end
