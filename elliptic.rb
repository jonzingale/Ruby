require 'benchmark'
require 'byebug'

module Factorization
	def factors(num)
		(1..Math.sqrt(num)).inject([]) {|fs,n| num % n == 0 ? fs += [n, num /n] : fs}
	end

	# Fermat Primes
	PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47].freeze

	def rmod(base, pow) ; rmod_logic base, pow, pow ; end
	def lookup(num) ; PRIMES.any?{|p| p == num} ; end

	def fermat(num,tol=2)
		num != 2 && num.even? ? false :
		num < 48 ? lookup(num) : rands(num/2).all? {|a| rmod(a,num) == a }
	end

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
		@m, @a = [m, rand(20)+1]
		@factor = pollard_factor
	end

	def pollard_factor
		@a = rmod_logic @a, @m, rand(@m)
		(factor = @m.gcd(@a)) > 1 ? factor : pollard_factor
	end
end

# def test(num)
# 	it = ECM.new(num)
# 	Benchmark.bm do |x|
# 		# x.report{ it.pollard_factor}
# 		# puts it.pollard_factor
# 	end
# end


it = ECM.new(5612)
them = it.pollard_factor


byebug ; 4
