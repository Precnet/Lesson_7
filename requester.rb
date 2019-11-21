module Requester
  private

  def get_request_parameters(parameters)
    if !parameters.empty?
      p parameters
      parameters.map { |parameter| get_parameter_from_user parameter[1].to_s }
    else
      nil
    end
  end

  def get_parameter_from_user(parameter)
    print "Enter #{parameter.split('_').join(' ')}: "
    gets.strip
  end
end
