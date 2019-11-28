# frozen_string_literal: true
module Requester
  private

  def get_request_parameters(parameters)
    result = parameters.map { |param| get_parameter_from_user param[1].to_s }
    result unless parameters.empty?
  end

  def get_parameter_from_user(parameter)
    print "Enter #{parameter.split('_').join(' ')}: "
    gets.strip
  end
end
