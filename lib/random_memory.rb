# encoding: utf-8
class RandomMemory

  class RandomMemoryExceeded < StandardError
  end

  require "set"

  # attr_reader :random_numbers

  def initialize(exclude_numbers: Set.new, lower_limit:1111, upper_limit:9999)
    @random_numbers = Set.new exclude_numbers.to_set
    @lower_limit = lower_limit
    @upper_limit = upper_limit
    update_limit
  end

  def update_limit
    @max_size = @upper_limit - @lower_limit + 1
  end

  def numbers_left
    @max_size - @random_numbers.length
  end

  def get_number
    if @random_numbers.length == @max_size
      raise RandomMemoryExceeded, "RandomMemory is exceeded: cannot generate new random number in permitted range."
    end
    begin
      r = rand(@lower_limit..@upper_limit)
    end while @random_numbers.member? r
    @random_numbers << r
    return r
  end

  def reset
    @random_numbers = Set.new
    upper_limit
  end

  def exclude(values)
    values = Set.new(values)
    @random_numbers += values
    update_limit
  end
end

