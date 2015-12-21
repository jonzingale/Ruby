require 'benchmark'
require 'byebug'

module Factorization
	def factors(num)
		(1..Math.sqrt(num)).inject([]) {|fs,n| num % n == 0 ? fs += [n, num /n] : fs}
	end

	def psinnum(p, n, i=1) ; n.gcd(p) == 1 ? i-1 : psinnum(p, n/p, i+1) ; end
	def totient(num) ; protmomma(num).map{|a,n| a**(n-1) * (a-1)}.inject :* ; end

	##### FERMAT PRIMES
	PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47].freeze

	def primates(tol=2, lim=100) ; (2..lim).select{|n| fermat n} ; end
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

class Modulus
	include Factorization
	attr_accessor :num, :len, :φ, :m, :rootφ, :pubkey, :prvkey

	def initialize(length)
		@num, @len = 0, length
		@φ, @m = get_modulus
		@rootφ = Math.sqrt @φ
		@prvkey = 0
		get_pubkey
		# inverse
	end

	def get_modulus
		p, q = get_fermat, get_fermat
		[p * q - p - q + 1, p * q]
	end

	def get_fermat
		big_num ; (@num-= 1) until fermat(@num) ; @num
	end

	def big_num
		(0...@len).each{|i| @num += rand(10) * 10 ** i} ; @num
	end

	def get_pubkey
		@pubkey = big_num # make this number @rootφ long.
		(@pubkey-= 1) until @φ.gcd(@pubkey) == 1
	end

	def get_pubkey2
		@pubkey2 = get_fermat # an idea?
		(@pubkey2-= 1) until @φ/(@pubkey2.to_f) - @φ/@pubkey2 == 0
	end


##
	def inverse
		windup ; @prvkey
	end

	def windup # this is super inefficient.
		@prvkey +=1
		until (@pubkey*@prvkey % @φ) == 1

			# byebug if @prvkey == 3
			windup
		end
	end
#########

	# def self.inverse(mod, num)
	# 	(2...mod).detect{|i| i * num % mod == 1}
	# end

	# def self.return_key_pair(modulus)
	# 	tot = totient modulus #<-- dont use this because I think up a pair of primes.
	# 	rtot = rand tot
	# 	(rtot = rand tot) unless rtot != 1 && rel_prime?(rtot, tot)

	# 	[rtot, self.inverse(tot, rtot)]
	# end

	# def self.encode(modulus)
	# 	# select a modulus, find the totient t
	# 	# choose a k,j pair such that k*j == 1 mod t
	# 	pr, qr = self.return_key_pair(modulus)
	# 	while qr.nil?
	# 		pr, qr = self.return_key_pair(modulus)
	# 	end
	# end
end

include Factorization

def test(num)
	mod = Modulus.new(num)

	Benchmark.bm do |x|
		x.report{ mod.pubkey }
	end
end


def thing(mod) # brute force inverse
	(1..1_000_000).detect{|i| i*mod.pubkey%mod.φ==1}
end

def example val # 3
mod = Modulus.new(val)# φ
msg = 5367
puts "\n\nmod.m = #{mod.m}\nmod.φ = #{mod.φ}\n"\
			"mod.pubkey = #{mod.pubkey}\npvkey = #{that=(thing mod)}\n"\
			"msg = #{msg}\nrmod_logic(msg,mod.m,that*mod.pubkey) = "\
			"#{rmod_logic(msg,mod.m,that*mod.pubkey)}"
end



mod = Modulus.new(3)# φ
that = thing(mod)

byebug ; 4

