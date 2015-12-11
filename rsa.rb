require 'byebug'

module Factorization

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
	def fermat(num,tol=2)
		[2,3].any?{|i| num == i} ? true :
		[4,6,15].any?{|i| num == i} ? false :
		# (0...tol).map {rand (num/2)}.all?{|a| rmod(a,num) == a}
		fast_list(num/2, tol).all?{|a| rmod(a,num) == a}
	end

	# 8 seconds for fermat primes < 1 M
	def fprimats(tol=2, lim=100)
		(2..lim).select{|n| fermat n}
	end

	def rmod base, pow, row=nil
		row = row||pow
		row < 10 ? (base**row) % pow : # find a best value < 10?
		row.even? ? (rmod(base, pow, row/2)**2) % pow :
		(base * rmod(base, pow, row/2)**2) % pow
	end

	# shuffled_list with a tol
	def fast_list len, tol
		lim = (Math.log(4.8265592) * len).floor
		len = tol.nil? ? len : tol
		(0...len).map do
			k = (lim-lim**2)/(2*Math.log(0.5))
			rand(k) % lim
		end
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

