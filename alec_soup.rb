# Alec Soup sans Gazpacho
require 'byebug'
require 'matrix'

# perhaps make graphs by selecting
# edges from the collection of all edges
# then counting the degree.

# what about the connectivity?

def graph num
	Matrix.build(num,num) { rand 2 }
end


verts = rand(25)
(0...verts).map{ rand 50}




byebug ; 4