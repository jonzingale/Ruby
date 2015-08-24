# It would be cool to see Q as a module
# which gets inherited into an Ant class.
require 'byebug'

def simple_answer
	(1..11).map{|i| Rational(1,i*3)}.inject :+
end

class Q
	def initialize(n,m=1)
		@q = [n,m]
	end

	def to_a ; @q ; end

	def to_f
		a, b = @q ; a / b.to_f
	end

	def +(it)
	 	a,b = @q.to_a
	 	x,y = it.to_a

	 	l = b.to_i.lcm(y.to_i)
	 	n = l / b
	 	m = y / b

	 	self.class.new(a*n + x*m, l)
	end

	def *(it)
	 	a,b = @q.to_a
	 	x,y = it.to_a
	 	self.class.new(a*x,b*y)
	end

	def re
		a, b = @q
		g = a.to_i.gcd(b.to_i)
		self.class.new(a/g,b/g)
	end
end

def walk(q)
	a, b = q.to_a
	q + Q.new(1,b)
end

def stretch(q)
	a, b = q.to_a
	n = (Q.new(a) * Q.new(b+3,b)).to_f
	Q.new(n,b+3)
end


def answer(i)
	init = Q.new(0,3)

	i.times do
		step = walk(init)
		init = stretch(step)
	end

	init.to_f

	puts "\n\nAfter #{i} steps the ant\n" \
			 "will be #{init.to_f}\n" \
			 "the way across the band\n\n"
end

answer(11)



def gcd(a,b)	
	if b == 0
		a
	else
		q = a < b ? [a, b % a] : [b, a % b]
		gcd(*q)
	end
end



byebug ; 4