# resource and path specializations.
# resource and path trophic levels.
require 'active_support/all'

	module Graphs
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
		end
	end

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
			@eval = self.non_sources
			@zero = @eval * 0
		end

		def is_source?(node)
			has_node = self.has_node?(node)
			heads_tails = @edges.values.map{|i|i[0..1]}
			has_node && heads_tails.none?{|s,t| t == node && s != t}
		end

		def non_sources
			src_ary = @nodes.keys.map{|n| self.is_source?(n) ? 0 : 1}
			Vector.elements(src_ary)
		end

		# path methods
		def walk(index,with_loop=false)
			index == 0 ? @id : self.transition(with_loop) ** index
		end

		def path_approx
			@approx, @approx_cond = 0 , nil # 98 % of energy acquired.
			while (@approx_cond.nil? || @approx_cond) && @approx < 10
				@approx_cond = self.walk(@approx+1,true).column(0).min <= 0.9999
				@approx += 1
			end ; @approx
		end

		def path_position
			approx = path_approx
			position_ary = @nodes.values.map do |index|
				(1..approx).map{|steps| walk(steps)[index,0] * steps}.inject :+
			end ; Vector.elements(position_ary)
		end

		def get_diagonal(matrix)
			raise 'not a square matrix' unless matrix.square?
			(0...matrix.row_count).map{|i| matrix[i,i]}
		end

		def path_variance
			approx = path_approx
			positions = self.path_position

			# nodes and probabilities
			path_probs = @nodes.values.map do |k|
				probs = (1..approx).map{|steps| walk(steps)[k,0]}
			end ; path_probs = Matrix.rows(path_probs)

			# nodes and position
			path_pos = (1..approx).map do |k|
				(positions -  k * @one).map{|t|t**2}
			end ; path_pos = Matrix.rows(path_pos)

			get_diagonal(path_probs * path_pos)
		end

		def path_specialization
			self.path_variance.map{|t| t**0.5}
		end
		# # # #

		# transition methods
		def trophic_variance(node)
			index = @nodes[node]
			positions = self.trophic_position
			masses = self.transition.row(index)

			# cannibalism handling
			unit = @id.row(index)
			cannibal_offset = masses[index] == 0 ? @one : @one - unit

			average_resource = positions[index] * @one - cannibal_offset
			dist = (positions - average_resource).map{|v| v ** 2}

			dist.inner_product masses
		end

		def resource_specialization(node)
			self.trophic_variance(node)**(0.5)
		end
		# # # #

		# y = (I - Q)^-1 * vect 1
		# Q are the non-source columns
		def trophic_position
			mtx, non_sources = self.transition, []

			mtx.column_vectors.each_with_index do |col,i|
				non_sources << (col[i] == 0 ? col : @zero)
			end

			q_matrix = Matrix.columns(non_sources)
			n_matrix = (@id - q_matrix).inverse
			y_vect = n_matrix * @eval
		end

		def transition(with_loop=false)
			# the probability that a unit of energy entering
			# component m was obtained directly from component n
			node_pair_rows = @nodes.keys.map{|n| @nodes.keys.map{|m| [n,m]}}

			weight_rows = node_pair_rows.map do |row|
				row.map do |s,t|
			    self.is_source?(s) && s==t ? (with_loop ? 1 : 0) :
					has_edge?(s,t) ? edges["%s_%s" % [s,t]].last : 0
				end
			end ; Matrix.columns(weight_rows)
		end
	end

include Graphs
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
