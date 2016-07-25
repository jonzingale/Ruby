# dyn as a list of sources and targets
require 'byebug'
require 'set'

class DSet
	attr_reader :closed, :states, :dyn, :pset

	def initialize(dyn)
		@states = dyn.map(&:first)
		@closed = closed_seqs dyn
		@pset = Set.new(powerset(@states))
		@dyn = dyn
	end

	def pp thing
		thing.map(&:to_a).map(&:to_s)
	end

	# not the right notion. 
	# i need all_seqs.
	def powerset(set)
	  return [set] if set.empty?

	  p = set.pop
	  subset = powerset(set)
	  subset | subset.map { |x| x | [p] }
	end

	def all_seqs
		
	end

	# def pset
	# 	pts = @states.count
	# 	str_st = @states.map(&:to_s)
	# 	bstrs = (0...2**pts).map{|t| "%0#{pts}d" % t.to_s(2)}
	# 	bins = bstrs.map{|t|t.split('').map(&:to_i)}
	# 	bins.map!{|bin| bin.zip(str_st).inject(''){|it,(b,c)| it << c*b } }
	# 	bins.map!{|t| t.split('')}
	# 	Set.new(bins)
	# end

	def open
		@pset - @closed
	end

	def closed_seqs dyn # the closed sets
		arys = dyn.inject([]) do |sq,(s, t)|
			elem = []

			while elem.index(t).nil?
				elem << s
				s, t = get_target(s, dyn)
			end

			sq << elem.sort
		end
		Set.new arys
	end

	def get_target s, dyn
		dyn[dyn[s][1]]
	end
end

def rand_dyn n
	(0...n).inject([]){|dyn, s| dyn << [s, rand(n)]}
end

test_dyn = [*0...6].zip [0, 0, 0, 1, 1, 2]
it = DSet.new(test_dyn)










byebug ; 4




