require 'benchmark'
require 'byebug'

# Todo: threading.
PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47].freeze
MERSENNE = (2**4423 - 1).freeze
BEST_TIME = 49.790000.freeze

# 49.790000 seconds for fermat primes < 10 M
def primates(tol=2, lim=100) ; (2..lim).select{|n| fermat n} ; end
def rmod(base, pow) ; rmod_worker base, pow, pow ; end

def fermat(num,tol=2)
	num != 2 && num.even? ? false :
	num < 48 ? lookup(num) : rands(num/2).all? {|a| rmod(a,num) == a }
end

private

def lookup(num) ; PRIMES.any?{|p| p == num} ; end

def rmod_worker base, pow, row
	row < 4 ? (base**row) % pow :
	row.even? ? (rmod_worker(base, pow, row/2)**2) % pow :
	(base * rmod_worker(base, pow, row/2)**2) % pow
end

#######
def rands num, tol=2 # psuedo-shuffle
	r = {} ; (r[rand(num)] = true) while (r.length < tol) ; r.keys
end

# may be better than rands for large arrays
# seek optimization in this direction.
def b_day_shuffle len
	lim = (Math.log(4.8265592) * len).floor
	(0...len).map do
		k = (lim-lim**2)/(2*Math.log(0.5))
		rand(k) % lim
	end
end
########

def test 
	Benchmark.bm do |x|
		x.report{ fermat MERSENNE, 20}
		x.report{ primates(2, 10_000_000) }
	end
end

puts "primes under 100: #{primates 2, 10**2}"
test

byebug ; 4 