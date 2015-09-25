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
		def initialize(nodes=[],weighted_edges={})
			@nodes = nodes # should better be hash for name clash.
			@edges = weighted_edges
		end

		def add_node(name=nil)
			@nodes << name 
		end

		def add_nodes(name_ary=[])
			@nodes += name_ary
		end

		def weight(edge)
			@edges[edge].nil? ? (raise 'no such edge') : @edges[edge].last
		end

		def has_node?(node)
			@nodes.any?{|n|n==node}
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

	class Levine
		# include Graphs
		require 'matrix'
		attr_reader :edges, :nodes, :id

		def initialize(graph)
			@edges = graph.edges
			@nodes = graph.nodes
			@count = @nodes.count
			@id = Matrix.identity(@count)
		end

		def has_node?(node)
			@nodes.any?{|n|n==node}
		end

		def is_source?(node)
			has_node = self.has_node?(node)
			heads_tails = @edges.values.map{|i|i[0..1]}
			has_node && heads_tails.none?{|s,t| t == node && s != t}
		end

		# Note: this is directed.
		# how can this inherit?
		def has_edge?(node_1, node_2)
			@edges["#{node_1}_#{node_2}"].present?
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
		# the node and probability associated with
		# energy reaching xi. k and xi being the
		# same type SET or index or otherwise.
		# then convert to integer for differencing.

		# again, as with path_length_probability,
		# this may be a bitch to calculate. A second
		# similar measure is based on the transition
		# matrix.
		# var(i) = sigma (xj - ri)^2 tij
		def trophic_spec(node)
			# let ri = xi - 1


		end

		def trophic_position_vector
			# y = (I - Q)^-1 * vect 1
			# Q is the non-source columns
			mtx, non_source = self.transition, []

			mtx.column_vectors.each_with_index do |col,i|
				non_source << (col[i] == 0 ? col : [0] * @count)
			end

			one_vect = Vector.elements([1] * @count)
			q_matrix = Matrix.columns(non_source)
			n_matrix = (@id - q_matrix).inverse
			y_vect = n_matrix * one_vect
		end

		def transition
			# the probability that a unit of energy entering
			# component m was obtained directly from component n
			node_pair_rows = @nodes.map{|n| @nodes.map{|m| [n,m]}}

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
trophic_vect = levine.trophic_position_vector

pp_it(trophic_vect)
pp_it(matrix)






byebug ; 4