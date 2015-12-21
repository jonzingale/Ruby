require 'benchmark'
require 'byebug'

module Factorization
	def factors(num)
		root = Math.sqrt num
		(1..root).inject([]) {|fs,n| num % n == 0 ? fs += [n, num /n] : fs}
	end

	def primes(lim=10000) ; (1..lim).select{|i| factors(i).count == 2} ; end
	def psinnum(p, n, i=1) ; n.gcd(p) == 1 ? i-1 : psinnum(p, n/p, i+1) ; end
	def totient(num) ; protmomma(num).map{|a,n| a**(n-1) * (a-1)}.inject :* ; end

	##### FACTORIZATIONS
	def hotmomma number # deterministic
		primes(number).inject([]) do |ps, p| 
			(pin = psinnum(p, number)) > 0 ? ps << [p, pin] : ps
		end
	end

	def protmomma num
		ary = [] # recursive & probabilistic, fast!
		primates(2,num).inject(num) do |num, p|
			(pin = psinnum(p, num)) > 0 ? (ary << [p, pin] ; num = num/(p**pin)) : num
		end ; ary
	end

	##### FERMAT PRIMES
	MERSENNE = (2**4423 - 1).freeze
	PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47].freeze

	# 48.650000 seconds for fermat primes < 10 M
	def primates(tol=2, lim=100) ; (2..lim).select{|n| fermat n} ; end
	def rmod(base, pow) ; rmod_logic base, pow, pow ; end

	def fermat(num,tol=2)
		num != 2 && num.even? ? false :
		num < 48 ? lookup(num) : rands(num/2).all? {|a| rmod(a,num) == a }
	end

	def lookup(num) ; PRIMES.any?{|p| p == num} ; end

	def rmod_logic base, pow, row
		row < 4 ? (base**row) % pow :
		row.even? ? rmod_logic(base, pow, row/2)**2 % pow :
		base * rmod_logic(base, pow, row/2)**2 % pow
	end

	def rands num, tol=2 # psuedo-shuffle
		r = {} ; (r[rand(num)] = true) while (r.length < tol) ; r.keys
	end
end

class Z_Prime # modulii can go.
	include Factorization
	attr_accessor :prime

	def initialize(prime)
		@prime = prime
	end

	# list rel_primes num
	def self.tots(num) ; (2..num).select{|rel| rel.gcd(num) == 1}.unshift 1 ; end
	def self.tots2(num) ; ((2..30).to_a - factors(30)).unshift 1 ; end

	def self.rel_prime?(a,b) ; (a.gcd b) == 1 ; end

	def self.inverse(mod, num)
		(2...mod).detect{|i| i * num % mod == 1}
	end

	def self.return_key_pair(modulus)
		tot = totient modulus #<-- dont use this because I think up a pair of primes.
		rtot = rand tot
		(rtot = rand tot) unless rtot != 1 && rel_prime?(rtot, tot)

		[rtot, self.inverse(tot, rtot)]
	end

	def self.encode(modulus)
		# select a modulus, find the totient t
		# choose a k,j pair such that k*j == 1 mod t
		pr, qr = self.return_key_pair(modulus)
		while qr.nil?
			pr, qr = self.return_key_pair(modulus)
		end
byebug
	end

end

include Factorization

def test num
	Benchmark.bm do |x|
		"\n\nprotmomma:\n"
		x.report{ protmomma num }

		"\n\nhotmomma:\n"
		x.report{ factors num }

		# x.report{ tots num }
	end
end

z_11 = Z_Prime.new(11)
puts "#{Z_Prime.tots2(30)}"
Z_Prime.encode(123)
# puts "#{them = Z_Prime.tots(30)}"

byebug ; 4

