# counter for instances of class
module InstanceCounter
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  # class methods
  module ClassMethods
    attr_accessor :number_of_instances

    def number_of_instances
      @number_of_instances ||= 0
    end
  end

  # instance methods
  module InstanceMethods
    private

    def register_instance
      self.class.number_of_instances ||= 0
      self.class.number_of_instances += 1
    end
  end
end
