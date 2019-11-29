require_relative 'railway_error.rb'

module Validator
  def valid?
    validate!
    true
  rescue RailwayError
    false
  end
end
