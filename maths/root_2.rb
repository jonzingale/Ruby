# calculate the second root
# based on an observation found
# in Pell's Equation x**2 - 2*y**2 = 1

require 'bigdecimal'

class Root2
  attr_reader :val

  def initialize num
    @a, @b = [ BigDecimal.new(1) ] * 2
    num.times { iterate }
  end

  def val
    @a / @b.to_f
  end

  def iterate
    @a, @b = @a*3 + @b*4, @a*2 + @b*3
  end
end

puts Root2.new(20).val