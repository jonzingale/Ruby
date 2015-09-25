# a place to calculate trophic_level.

# some data sets:
# personal banking? banking versus walking paths?
# jackrabbit food webs?
#  
require 'byebug'
require 'active_support/all'

# Pass objects for nodes, methods for edges?
module Graphs

	class Node# todo: nodify objects
		def initialize(thing=nil)
			@thing = thing
			@nodes = node # should better be hash for name clash.
		end
	end

	class DiGraph
		attr_reader :edges, :weight, :nodes
		def initialize(nodes={},weighted_edges={})
			@edges = weighted_edges
			@nodes = nodes
		end

		def add_node(name_str)
			@nodes[name_str] = @nodes.count
		end

		def add_nodes(name_ary=[])
			name_ary.each{|name| self.add_node(name) }
		end

		def weight(edge)
			@edges[edge].nil? ? (raise 'no such edge') : @edges[edge].last
		end

		def has_node?(node)
			@nodes.keys.any?{|n|n==node}
		end

		# note: this is directed.
		def has_edge?(node_1, node_2)
			@edges["#{node_1}_#{node_2}"].present?
		end

		# weight is more complicated, as it
		# depends on the nature of the network.
		def add_edge(src,trg,weight=0)
			node_cond = has_node?(src) && has_node?(trg)
			raise 'No such Nodes' unless node_cond

			name = "#{src}_#{trg}"
			@edges[name] = [src,trg,weight]
		end

		# Todo: cohomology, cyclomatics?
	end

	def pp_it(obj)
		if obj.is_a?(Vector)
			obj.map{|t|t.to_f.round 2}
		elsif obj.is_a?(Matrix)
			(0...obj.column_count).each do |i| 
				puts obj.row(i).map{|t| t.to_f.round 2}
			end
		end
	end

end
###############
include Graphs

	class Levine#<DiGraph?
		# include Graphs
		require 'matrix'
		attr_reader :edges, :nodes, :id, :eval

		def initialize(graph)
			@graph = graph
			@edges = graph.edges
			@nodes = graph.nodes

			@id = Matrix.identity(@nodes.count)
			@eval = self.non_source
			@zero = @eval * 0
		end

		def has_node?(node)
			@graph.has_node?(node)
		end

		def is_source?(node)
			has_node = self.has_node?(node)
			heads_tails = @edges.values.map{|i|i[0..1]}
			has_node && heads_tails.none?{|s,t| t == node && s != t}
		end

		def non_source
			src_ary = @nodes.keys.map{|n| self.is_source?(n) ? 0 : 1}
			Vector.elements(src_ary)
		end

		# Note: this is directed.
		def has_edge?(node_1, node_2)
			@graph.has_edge?(node_1, node_2)
		end

		def tropic_height(node)
			if self.is_source?(node)
				1
			else
				# todo: start a calculation of all paths.
				# and compute upto 90 % of diet.
				# xi = sigma k*pi(k)
				# where sigma from 0 to inf
				# i is component, k is path length
			end
		end

		def path_length_probability(k)
			# should compute trophic position from
			# contribution of paths of given lengths.
			# How do I test that there are only n 
			# paths of length k from a source to a 
			# given component?

			# multiplications?
		end

		# var(i) = sigma (k-xi)^2 * pi(k)
		# where sigma ranges from k=0 to infinity
		# k being a path length and xi and pi are
		# the trophic position and probability 
		# associated with energy reaching xi.
		# alternatively .. .
		def trophic_spec(node)
# :(s2) = Σ [(xi - x̅)2]/n - 1.
# s2 = Variance
# Σ = Summation, which means the sum of every term in the equation after the summation sign.
# xi = Sample observation. This represents every term in the set.
# x̅ = The mean. This represents the average of all the numbers in the set.
# n = The sample size. You can think of this as the number of terms in the set.
# from nets

			# var(i) = Σ(xj - ri)^2 tij
			# where ri = xi - 1

			# [0,1,2.08,1.47,2.33] x
			# [0,0,0.95,0.99,0.85] sig
			# [0,0,0.57,0.93,0.13] sig_h

			# i am getting [1.0, 0.0, 0.32, 0.87, 0.05]

			index = @nodes[node]
			ti = self.transition.row(index)
			ri = self.trophic_position[index] - 1 # <-- why minus 1?
			xjs = self.trophic_position

			var = xjs.map{|xj| (xj - ri)**2}
			dot_prod(var,ti)
		end

		def dot_prod(vect,wect) ; vect.zip(wect).map{|v,w| v*w}.inject :+ ; end

		def trophic_position
			# y = (I - Q)^-1 * vect 1
			# Q are the non-source columns
			mtx, non_source = self.transition, []

			mtx.column_vectors.each_with_index do |col,i|
				non_source << (col[i] == 0 ? col : @zero)
			end

			q_matrix = Matrix.columns(non_source)
			n_matrix = (@id - q_matrix).inverse
			y_vect = n_matrix * @eval
		end

		def transition
			# the probability that a unit of energy entering
			# component m was obtained directly from component n
			node_pair_rows = @nodes.keys.map{|n| @nodes.keys.map{|m| [n,m]}}

			weight_rows = node_pair_rows.map do |row|
				row.map do |s,t|
					self.is_source?(s) && s==t ? 1 :
					has_edge?(s,t) ? edges["%s_%s" % [s,t]].last : 0
				end
			end

			Matrix.columns(weight_rows)
		end

	end

########
	# from Williams & Martinez
	# Calculates the trophic level
	# of each component in a complete graph.
	def trophic_k(n=1,sum=1,i=1,accum=[])
		if n == 1 || i == 1
			tot = i
		else
			tot = 1 + (i-1)**-1 * sum
			sum += tot
		end
		accum << tot
		trophic_k(n,sum,i+1,accum) unless n == i
		accum
	end
	
	# many = trophic_k 2000
	
	# them = many.map.with_index do |elem,n| 
	# 	ratio = elem/(n+1).to_f.round(3)
	# end.map(&:to_f)
	
	# puts them
	
	##########

it = DiGraph.new
it.add_nodes(['me','you','them','these'])
it.add_edge('you','me',Rational(0.5))
it.add_edge('you','you',1)

weight = it.weight('you_me')

trop_it = Levine.new(it)
is_basal = trop_it.is_source?('you')

# levine's paper
graph = DiGraph.new
graph.add_nodes((1..5).map &:to_s)
graph.add_edge('1','2',Rational(1.0))
graph.add_edge('1','3',Rational(0.2))
graph.add_edge('1','4',Rational(0.8))
graph.add_edge('2','3',Rational(0.2))
graph.add_edge('4','5',Rational(0.7))
graph.add_edge('5','4',Rational(0.2))
graph.add_edge('4','3',Rational(0.6))
graph.add_edge('2','5',Rational(0.3))

levine = Levine.new(graph)
is_basal = levine.is_source?('you')

sources = levine.nodes.select{|node| levine.is_source?(node) }

# an absorbing markov chain.
matrix = levine.transition
trophic_vect = levine.trophic_position.map{|t| t.to_f.round 2}
var_3 = levine.trophic_spec('3')

pp_it(trophic_vect)
pp_it(matrix)



# Sarah's Graph
sarah = DiGraph.new
sarah.add_nodes(('a'..'o').map &:to_s)
sarah.add_edge('a','b',Rational(1.0))
sarah.add_edge('b','c',Rational(1/2.0))
sarah.add_edge('c','d',Rational(1.0))
sarah.add_edge('d','e',Rational(1.0))
sarah.add_edge('e','f',Rational(1/3.0))
sarah.add_edge('g','h',Rational(1.0))
sarah.add_edge('h','c',Rational(1/2.0))
sarah.add_edge('i','j',Rational(1.0))
sarah.add_edge('j','k',Rational(1.0))
sarah.add_edge('k','l',Rational(3/4.0))
sarah.add_edge('l','m',Rational(1.0))
sarah.add_edge('m','f',Rational(2/3.0))
sarah.add_edge('n','o',Rational(1.0))
sarah.add_edge('o','l',Rational(1/4.0))

tr_sarah = Levine.new(sarah)
sarah_pos = tr_sarah.trophic_position
var_f = tr_sarah.trophic_spec('f')

# a simple third
simple = DiGraph.new
simple.add_nodes((0..5).map &:to_s)
simple.add_edge('0','2',0.5)
simple.add_edge('1','2',0.5)

simple.add_edge('2','3',1)
simple.add_edge('3','4',1)
simple.add_edge('4','5',1)

tr_simple = Levine.new(simple)
simple_pos = tr_simple.trophic_position
var_2 = tr_simple.trophic_spec('2')

vars = levine.nodes.keys.map{|t| levine.trophic_spec(t).to_f}

byebug ; 4