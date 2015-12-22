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
	attr_accessor :num, :len, :φ, :m, :rootφ,
								:pubkey, :prvkey

	def initialize(length)
		@num, @len = 0, length
		@φ, @m = get_modulus
		@rootφ = Math.sqrt @φ
		get_pubkey ; get_prvkey
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

######### attempts at inverses.
def get_prvkey ; @prvkey = inverse ; end

def inverse # brute force inverse
	start = @φ/@pubkey
	(start..@φ).detect{|i| i*@pubkey % @φ == 1}
end

	# def self.inverse(mod, num)
	# 	(2...mod).detect{|i| i * num % mod == 1}
	# end
end

include Factorization

def test(num)
	mod = Modulus.new(num)

	Benchmark.bm do |x|
		# x.report{ thing mod }
		# x.report{ thing2 mod }
	end
end

def example val # 4
mod = Modulus.new(val)# φ
msg = 5367
puts "\n\nmod.m = #{mod.m}\nmod.φ = #{mod.φ}\n"\
			"mod.pubkey = #{mod.pubkey}\nmod.pvkey = #{mod.prvkey}\n"\
			"msg = #{msg}\nrmod_logic(msg,mod.m,mod.prvkey*mod.pubkey) = "\
			"#{rmod_logic(msg,mod.m,mod.prvkey*mod.pubkey)}"
end


mod = Modulus.new(4)# φ

byebug ; 4

