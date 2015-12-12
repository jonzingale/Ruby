require 'benchmark'
require 'byebug'

module Factorization
	def baseList(num) ; num < 10 ? [num] : baseList(num/10) << (num % 10) ; end
	def div_3?(num) ; baseList(num).inject(0,:+) % 3 == 0 ; end

	def div_11? num
		ns = baseList(num)
		diff = ns.zip(ns.drop 1).map{|a,b| b.nil? ? 0 : a-b}
		diff.inject(:+) % 11 == 0
	end

	def psinnum(p, n, i=1)
		n.gcd(p) == 1 ? i-1 : psinnum(p,n/p,i+1)
	end

	def totient num
		hotmomma(num).map{|a,n| a**(n-1) * (a-1)}.inject :*
	end

	def factors(num)
		root = Math.sqrt num
		(1..root).inject([]) {|fs,n| num % n == 0 ? fs += [n, num /n] : fs}
	end

	def primes(lim=10000)
		(1..lim).select{|i| factors(i).count == 2}
	end

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

##### BIRTHDAY SHUFFLES
	def b_day_shuffle len
		lim = (Math.log(4.8265592) * len).floor
		(0...len).map do
			k = (lim-lim**2)/(2*Math.log(0.5))
			rand(k) % lim
		end
	end

	# shows power law for shuffled's 
	# 23 -> 14, 230 -> 146, 2300 -> 1461, ...
	def find_avg(num) # k ~ 0.63527
		(0..200).inject(0){|sum, i| sum += b_day_shuffle(num).uniq.count}/200
	end

##### FERMAT PRIMES
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

########
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
		hotmomma(num).map{|a,n| a**(n-1) * (a-1)}.inject :*
	end

	def inverse()

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

