require 'byebug'
require 'benchmark'

BEST_TIME = 51.570000.freeze
MERSENNE = (2**4423 - 1).freeze
PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47].freeze

def lookup(num) ; PRIMES.any?{|p| p == num} ; end

def fermat(num,tol=2)
	num != 2 && num.even? ? false :
	num < 48 ? lookup(num) : rands(num/2).all? {|a| rmod(a,num) == a }
end

def rmod base, pow, row=nil	
	(row = row||pow) < 4 ? (base**row) % pow :
	row.even? ? (rmod(base, pow, row/2)**2) % pow :
	(base * rmod(base, pow, row/2)**2) % pow
end

def rands num, tol=2 # psuedo-shuffle
	r = {} ; (r[rand(num)] = true) while (r.length < tol) ; r.keys
end

# 51.570000 seconds for fermat primes < 10 M
def primates tol=2, lim=100
	(2..lim).select{|n| fermat n}
end

def test 
	Benchmark.bm do |x|
		x.report{ fermat MERSENNE, 20}
		x.report{ primates(2, 10_000_000) }
	end
end

puts "primes under 100: #{primates 2, 10**2}"
test

byebug ; 4 