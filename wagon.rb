require_relative 'company.rb'

class Wagon
  include Company

  def initialize(number)
    @number = number
  end

  attr_reader :type, :number
end
