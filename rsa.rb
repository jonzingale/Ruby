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

	def rel_prime?(a,b) ; (a.gcd b) == 1 ; end

	def factors(num)
		root = Math.sqrt num
		(1..root).inject([]) {|fs,n| num % n == 0 ? fs += [n, num /n] : fs}
	end

	def primes(lim=10000)
		(1..lim).select{|i| factors(i).count == 2}
	end

	def hotmomma number
		primes(number).inject([]) do |ps, p| 
			(pin = psinnum(p, number)) > 0 ? ps << [p, pin] : ps
		end
	end

	def rotmomma number # recursive
		ps = primes number
		good_p = ps.select{|p| psinnum(p,number) > 0}

		ary = []
		primes(number).inject(number) do |num, p|
			(pin = psinnum(p, num)) > 0 ? (ary << [p, pin] ; num = num/p) : num
		end ; ary
	end

##### BIRTHDAY SHUFFLES
	# via Feller's approximation
	# to the birthday problem
	def shuffled_list len
		lim = (Math.log(4.8265592) * len).floor
		(0...len).map do
			k = (lim-lim**2)/(2*Math.log(0.5))
			rand(k) % lim
		end
	end

	# shows power law for shuffled's 
	# 23 -> 14, 230 -> 146, 2300 -> 1461, ...
	def find_avg(num) # k ~ 0.63527
		(0..200).inject(0){|sum, i| sum += shuffled_list(num).uniq.count}/200
	end

##### FERMAT PRIMES
	PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47].freeze

	def lookup(num) ; PRIMES.any?{|p| p == num} ; end

	def fermat(num,tol=2)
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
########
end


class Z_Prime
	include Factorization
	attr_accessor :prime, :totient

	def initialize(prime)
		@prime = prime
		@totient = totient(prime)
	end

	def totient(num)

	end

	def inverse()

	end

	def encode

	end

end


include Factorization

# rmod 9365, 7700
# hotmomma 24
# psinnum 2, 24
# rmod 19, 21
byebug ; 4

