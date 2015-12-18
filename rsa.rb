require 'benchmark'
require 'byebug'

module Factorization
	def factors(num)
		root = Math.sqrt num
		(1..root).inject([]) {|fs,n| num % n == 0 ? fs += [n, num /n] : fs}
	end

	def primes(lim=10000) ; (1..lim).select{|i| factors(i).count == 2} ; end
	def psinnum(p, n, i=1) ; n.gcd(p) == 1 ? i-1 : psinnum(p,n/p,i+1) ; end

	##### FACTORIZATIONS
	def hotmomma number # deterministic
		primes(number).inject([]) do |ps, p| 
			(pin = psinnum(p, number)) > 0 ? ps << [p, pin] : ps
		end
	end

	def protmomma num
		ary = [] # recursive & probabilistic, fast!
		primates(2,num).inject(num) do |num, p|
			(pin = psinnum(p, num)) > 0 ? (ary << [p, pin] ; num = num/p) : num
		end ; ary
	end

	##### FERMAT PRIMES
	MERSENNE = (2**4423 - 1).freeze
	PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47].freeze

	def primates(tol=2, lim=100) ; (2..lim).select{|n| fermat n} ; end
	def rmod(base, pow) ; rmod_worker base, pow, pow ; end
	def lookup(num) ; PRIMES.any?{|p| p == num} ; end

	def fermat(num,tol=2)
		num != 2 && num.even? ? false :
		num < 48 ? lookup(num) : rands(num/2).all? {|a| rmod(a,num) == a }
	end

	def rmod_worker base, pow, row
		row < 4 ? (base**row) % pow :
		row.even? ? (rmod_worker(base, pow, row/2)**2) % pow :
		(base * rmod_worker(base, pow, row/2)**2) % pow
	end

	def rands num, tol=2 # psuedo-shuffle
		r = {} ; (r[rand(num)] = true) while (r.length < tol) ; r.keys
	end
end

class Z_Prime
	include Factorization
	attr_accessor :prime

	def initialize(prime)
		@prime = prime
	end

	# list rel_primes num
	def self.tots(num) ; (2..num).select{|rel| rel.gcd(num) == 1}.unshift 1 ; end
	def rel_prime?(a,b) ; (a.gcd b) == 1 ; end

	def self.totient num
		protmomma(num).map{|a,n| a**(n-1) * (a-1)}.inject :*
	end

	def inverse

	end

	def encode

	end

end

include Factorization
BIG = 7957792.freeze

def test num
	Benchmark.bm do |x|
		# x.report{ hotmomma num }
		# x.report{ protmomma num }

		# x.report{ tots num }
	end
end

z_11 = Z_Prime.new(11)
puts "#{them = Z_Prime.tots(30)}"
byebug ; 4

