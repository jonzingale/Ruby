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
			@nodes = node
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
		puts "\n\n"
		if obj.is_a?(Vector)
			obj.map{|t|t.to_f.round 2}
		elsif obj.is_a?(Matrix)
			(0...obj.column_count).each do |i| 
				puts obj.row(i).map{|t| t.to_f.round 2}
			end
		elsif obj.is_a?(Array)
			puts obj.map{|t|t.round(2)}.to_s
		end
		puts "\n\n"
	end

end
###############

	include Graphs

	class Levine < DiGraph
		include Graphs
		require 'matrix'
		attr_reader :edges, :nodes, :id, :eval

		def initialize(graph)
			@graph = graph
			@edges = graph.edges
			@nodes = graph.nodes
			count = @nodes.count

			@id = Matrix.identity(count)
			@one = Vector.elements([1] * count)
			@eval = self.non_source
			@zero = @eval * 0
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

		# path method
		# TODO:
		# def tropic_height(node)
		# 	if self.is_source?(node)
		# 		1
		# 	else
		# 		# todo: start a calculation of all paths.
		# 		# and compute upto 90 % of diet.
		# 		# xi = Σ k*pi(k), Σ 0..inf
		# 		# i is component, 
		# 		# k is path length
		# 	end
		# end

		# def path_length_probability(k)
		# 	# should compute trophic position from
		# 	# contribution of paths of given lengths.
		# 	# How do I test that there are only n 
		# 	# paths of length k from a source to a 
		# 	# given component?		
		# end
		# # # #

		# transition method
		def trophic_variance(node)
			index = @nodes[node]
			positions = self.trophic_position
			masses = self.transition.row(index)

			# handles the case of cannibalism
			unit = @id.row(index)
			cannibal_offset = masses[index] == 0 ? @one : @one - unit

			average_resource = positions[index] * @one - cannibal_offset
			dist = (positions - average_resource).map{|v| v ** 2}

			dot_prod(dist,masses)
		end

		def specialization(node)
			self.trophic_variance(node)**(0.5)
		end
		# # # #

		# y = (I - Q)^-1 * vect 1
		# Q are the non-source columns
		def trophic_position
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
				row.map do |s_t|
					has_edge?(*s_t) ? edges["%s_%s" % s_t].last : 0
				end
			end

			Matrix.columns(weight_rows)
		end

		private

		def dot_prod(vect,wect)
			vect.zip(wect).map{|v,w|v*w}.inject :+
		end
	end

######## Williams & Martinez

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

# # calculates how fast the max tropic position 
# # drops as number nodes goes to infinity
# them = many.map.with_index do |elem,n| 
# 	ratio = elem/(n+1).to_f.round(3)
# end.map(&:to_f)
# puts them

########### Levine

graph = DiGraph.new
graph.add_nodes((1..5).map &:to_s)
# graph.add_edge('1','1',1.0) # source
graph.add_edge('1','2',1.0)
graph.add_edge('1','3',0.2)
graph.add_edge('1','4',0.8)
graph.add_edge('2','3',0.2)
graph.add_edge('4','5',0.7)
graph.add_edge('5','4',0.2)
graph.add_edge('4','3',0.6)
graph.add_edge('2','5',0.3)

levine = Levine.new(graph)
is_basal = levine.is_source?('you')

matrix = levine.transition
trophic_vect = levine.trophic_position
std_dev = levine.nodes.keys.map{|k| levine.specialization(k) }

pp_it(std_dev)

byebug ; 4