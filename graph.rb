#!/usr/bin/env ruby

# http://jacquerie.github.io/hh/

require 'set'

class GraphNode
  def initialize(name, desired_connections)
    @name = name
    @desired_connections = desired_connections
    @connected_nodes = []
  end

  def ==(node)
    if node
      name == node.name
    end
  end

  def <=>(node)
    name <=> node.name
  end

  def name
    @name
  end
  alias_method :inspect, :name

  def to_s
    "#{name} (#{connection_count}/#{@desired_connections}): #{@connected_nodes.sort}"
  end

  def connection_count
    @connected_nodes.length
  end

  def balance
    @desired_connections - @connected_nodes.length
  end

  def balanced?
    balance == 0
  end

  def connect(node)
    @connected_nodes << node
    node.be_connected(self)
  end

  def be_connected(node)
    !!(@connected_nodes << node)
  end

  def disconnect(node)
    @connected_nodes = @connected_nodes - [node]
    node.be_disconnected(self)
  end

  def be_disconnected(node)
    !!(@connected_nodes = @connected_nodes - [node])
  end

  def connected?(node)
    @connected_nodes.include?(node)
  end

  def reset!
    @connected_nodes = []
  end
end

class Graph
  def initialize(values)
    @nodes = []
    i = 0
    if values.is_a? Array
      values.each_with_index do |v, i|
        @nodes << GraphNode.new(i, v)
      end
    else
      @nodes = values.map{ |k, v| GraphNode.new(k, v) }
    end
  end

  def nodes
    @nodes
  end

  def to_s
    "Graph #{status}\n" + @nodes.join("\n")
  end

  def random_node
    @nodes[rand(@nodes.length)]
  end

  def random_unbalanced_node(not_this_node=nil)
    unbalanced_nodes = @nodes.reject do |node|
      node == not_this_node || node.balanced? ||
              (not_this_node && node.connected?(not_this_node))
    end
    unbalanced_nodes[rand(unbalanced_nodes.length)]
  end

  def connect_random_pair
    if (
      (node1 = random_unbalanced_node) &&
      (node2 = random_unbalanced_node(node1))
    )
      node1.connect(node2)
    end
  end

  def connect_all
    while (!balanced? && !broken?)
      break unless connect_random_pair
    end
  end

  def balanced?
    @nodes.map(&:balance).max == 0 && !broken?
  end

  def broken?
    @nodes.map(&:balance).min < 0
  end

  def unbalanced_nodes
    @nodes.reject(&:balanced?).length
  end

  def missing_connections
    @nodes.map(&:balance).reduce :+
  end

  def status
    if unbalanced_nodes == 0
      "is balanced"
    else
      "has #{unbalanced_nodes} unbalanced nodes and #{missing_connections} missing connections"
    end
  end

  def reset!
    @nodes.each do |node|
      node.reset!
    end
  end
end

def rand_solve_graph(values, tries)
  solutions = Set.new
  best_graph = Graph.new(values)
  tries.times do |i|
    g = Graph.new(values)
    g.connect_all
    best_graph = g if (
      (g.unbalanced_nodes < best_graph.unbalanced_nodes) &&
      (g.missing_connections < best_graph.missing_connections)
    )
    solutions << g.to_s if g.balanced?
  end
  if solutions.length > 0
    puts "Found #{solutions.length} distinct solutions:"
    puts solutions.to_a.join("\n\n")
  else
    puts "Closest solution found was:"
    puts best_graph
  end
  return solutions
end

puzzles = [
  {
    green: 4,
    red: 3,
    dark_blue: 2,
    light_blue: 2,
    orange: 1
  },
  {
    purple: 4,
    yellow: 4,
    light_blue: 3,
    grey: 3,
    pink: 2,
    brown: 2
  },
  {
    pink: 5,
    grey: 4,
    yellow: 4,
    brown: 3,
    blue: 3,
    purple: 3
  }
]

solutions = rand_solve_graph(puzzles[1], 10000)
# solutions = rand_solve_graph([12,9,8,8,7,6,6,6,5,4,4,4,3,2,2], 1000)


