# burrows-wheeler transform
require 'matrix'

BANANA= '^BANANA'
NOT_BWT = "\n Missing |, not an encoding \n"

# forward direction
def bwt(string)
  list = (string+"|").split('')
  rots = (1..list.length).map{|it|list.rotate(it)}
  matrix_op(rots.sort).last.join("")
end

# inverse direction
def inv_bwt(string)
  block(string.split(''),[])
end

def block(key,build)
  if build.empty?
    block(key,[key])
  elsif key.length == build.length
    array = matrix_op(build).detect{|d|d.last=="|"}
    array.nil? ? (puts NOT_BWT) : array.take_while{|d|d != "|"}.join("")
  else
    trans = matrix_op(matrix_op(build).sort)
    block(key,[key]+trans)
  end
end

def matrix_op(ary)# :: [[a]] -> [[a]]
  Matrix.columns(ary).to_a
end

puts "enter a string to encode"
puts bwt(gets.chomp)
puts "enter a string to decode"
puts inv_bwt(gets.chomp)
puts "hit any key to continue"
gets.chomp
puts "^BANANA encoded"
puts bwt(BANANA)
puts "BNN^AA|A decoded"
puts inv_bwt(bwt(BANANA))



