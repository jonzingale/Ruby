require 'byebug'
require 'benchmark'

BEST_TIME = 4.720000.freeze
MERSENNE = (2**4423 - 1).freeze
PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47].freeze

def lookup(num) ; PRIMES.any?{|p| p == num} ; end

def fermat(num,tol=2)
	# even?
	num < 48 ? lookup(num) : rands(num/2).all?{|a| rmod(a,num) == a}
end

def rmod base, pow, row=nil	
	(row = row||pow) < 4 ? (base**row) % pow :
	row.even? ? (rmod(base, pow, row/2)**2) % pow :
	(base * rmod(base, pow, row/2)**2) % pow
end

def rands num, tol=2 # better shuffling.
	r = {} ; (r[rand(num)] = true) while (r.length < tol) ; r.keys
end

# 4.72 seconds for fermat primes < 1 M
def fprimats tol=2, lim=100
	(2..lim).select{|n| fermat n}
end

Benchmark.bm do |x|
	x.report{ fprimats(2, 1000000) }
	x.report{ fermat MERSENNE}
end
puts "#{fprimats 2, 10**3}"

byebug ; 4


