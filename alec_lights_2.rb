require 'byebug'
require 'matrix'

def light_ops num
  a1 = Array.new(num-2, 0)
  a2 = Array.new(num-3, 0)
  first = [1,1] + a1
  last = a1 + [1,1]
  accum = [first]

  (num-2).times do |i|
    head, tail = a2.take(i), a2.drop(i)
    accum << head + [1,1,1] + tail
  end

  Matrix.rows(accum << last)
end

100.times do |i|
  matrix = light_ops i+3
  dims = matrix.rank
  if dims != i+3
    puts [i+3, dims].to_s
  end
end

# congruent to 2 `mod` 3 have
# unsolvable initial conditions.