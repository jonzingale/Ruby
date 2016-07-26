# dyn as a list of sources and targets
require 'byebug'
require 'set'

class DSet
	attr_reader :closed, :states, :dyn, :pset

	def initialize(dyn)
		@states = dyn.map(&:first)
		@closed = closed_seqs dyn
		@pset = nil
		@dyn = dyn
	end

	def all_seqs
		# how do i get these?
	end

	def open
		@pset - @closed
	end

	def closed_seqs dyn
		closed = closed_basis dyn
		empty = Set.new []

		seqs = closed.inject(empty) do |u,p|
			u | closed.map{|t| Set.new(t|p)}
		end
	end

	def closed_basis dyn
		arys = dyn.inject([]) do |sq,(s, t)|
			elem = []

			while elem.index(t).nil?
				elem << s
				s, t = dyn[dyn[s][1]]
			end

			sq << elem.sort
		end
	end
end

def rand_dyn n
	(0...n).inject([]){|dyn, s| dyn << [s, rand(n)]}
end

test_dyn = [*0...6].zip [0, 0, 0, 1, 1, 2]
it = DSet.new(test_dyn)

puts it.closed.map(&:to_a).to_s


byebug ; 4




