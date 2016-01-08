# require 'byebug'

class Lorenz
	Eball = 0.01
	attr_reader :x, :y, :z, :pts
	def initialize(x=nil, y=nil, z=nil)
		@x = x||rand(17) # -18 < x <18
		@y = y||rand(23) # -24 < y < 24
		@z = z||rand(44) # 4 < z < 45
		@pts = blink
	end

	def dx ; 10 * (@y - @x) ; end
	def dy ; @x * (28 - @z) - @y ; end
	def dz ; @x * @y - @z * 8 / 3.0  ; end

	def blink
		[@x = Eball*dx + @x,
		 @y = Eball*dy + @y,
		 @z = Eball*dz + @z]
	end
end

# uncomment when testing
# it = Lorenz.new
# go = (0...10).map{ it.blink }
# byebug ; 4