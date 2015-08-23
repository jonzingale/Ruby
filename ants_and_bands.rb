require 'byebug'
require 'matrix'

class Vect
	def initialize(array) ; @vect = Vector.elements(array) ; end
	def last ; @vect.to_a.last ; end
	def to_v ; @vect ; end
end

class Q
	def initialize(n,m=1)
		@q = [n,m]
	end

	def to_a ; @q ; end

	def to_f
		a, b = @q ; a / b.to_f
	end

	def *(it)
	 	a,b = @q.to_a
	 	x,y = it.to_a
	 	self.class.new(a*x,b*y)
	end

	def re
		a, b = @q
		g = gcd(a, b)
		self.class.new(a/g,b/g)
	end

	def gcd(a, b)
		a, b = [b, a] if a > b
		vect = Vect.new([1, 0, a])
		wect = Vect.new([0, 1, b])
	
		until wect.last == 0
			vect, wect = vect.last < wect.last ? [vect, wect] : [wect, vect]
			wect = Vect.new(wect.to_v - vect.to_v)
		end

		vect.last
	end

end

def walk(n,m)
	[n+1, m]
end

def stretch(a,b)
	m = b + 3
	n = (Q.new(m, b) * Q.new(a)).re
	(n * Q.new(1, m)).to_a
end


def answer(i)
	init = [0,3]

	until i == 0
		i -= 1
		step = walk(*init)
		init = stretch(*step)
	end ; Q.new(*init).to_f
end

answer(6)

# too buggy for answer 7.
