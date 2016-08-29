require 'benchmark'
require 'byebug'

module Factorization
	def rmod(base, pow) ; rmod_logic base, pow, pow ; end

	def rmod_logic base, pow, row
		row < 4 ? (base**row) % pow :
		row.even? ? rmod_logic(base, pow, row/2)**2 % pow :
		base * rmod_logic(base, pow, row/2)**2 % pow
	end

	def rands num, tol=2 # psuedo-shuffle
		r = {} ; (r[rand(num)] = true) while (r.length < tol) ; r.keys
	end
end

class ECM
	include Factorization
	attr_reader :m, :a, :factor
	def initialize(m)
		# could use a better distribution of rands.
		@m, @a = [m, rand(m-2)+1]
		@factor = pollard_factor
	end

	def pollard_factor
		@a = rmod_logic @a, @m, rand(@m)
		(factor = @m.gcd(@a-1)) > 1 ? factor : pollard_factor
	end
end

def test(num)
	composite = ECM.new(num)

	Benchmark.bm do |x|
		x.report{ composite.pollard_factor}
		puts "#{composite.pollard_factor}"
	end
end

it = ECM.new(5612)
them = it.pollard_factor
puts them

byebug ; 4
