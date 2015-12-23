require 'benchmark'
require 'byebug'

# Todo: threading.
PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47].freeze
Mersenne = (2**4423 - 1).freeze
BigMersenne = (2**9689 - 1)
Fermat = (2**2**4+1).freeze
BEST_TIME = 48.650000.freeze

# 48.650000 seconds for fermat primes < 10 M
def primates(tol=2, lim=100) ; (2..lim).select{|n| fermat n} ; end
def rmod(base, pow) ; rmod_logic base, pow, pow ; end

def fermat(num, tol=2)
	num != 2 && num.even? ? false :
	num < 48 ? lookup(num) : rands(num/2).all? {|a| rmod(a,num) == a }
end

private

def lookup(num) ; PRIMES.any?{|p| p == num} ; end

def rmod_logic base, pow, row
	row < 4 ? (base**row) % pow :
	row.even? ? rmod_logic(base, pow, row/2)**2 % pow :
	base * rmod_logic(base, pow, row/2)**2 % pow
end

def rands num, tol=2 # psuedo-shuffle
	r = {} ; (r[rand(num)] = true) while (r.length < tol) ; r.keys
end

def test
	puts "\nprimes under 100:\n#{primates 2, 10**2}\n\n"

	Benchmark.bm do |x|
		puts "\nfermat (2**4423 - 1)"
		x.report{ fermat Mersenne, 20}
		puts "\nprimates(2, 1_000_000)"
		x.report{ primates(2, 1_000_000) }
		# puts "\nprimates(2, 10_000_000)"
		# x.report{ primates(2, 10_000_000) }
	end
end

# test

byebug ; 4
