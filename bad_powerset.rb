require 'benchmark'

def get_subsets size
  (0...2**size).map do |x|
    num = "%0#{size}d" % x.to_s(2)
    num.split('').map(&:to_i)
  end
end

def powerset array
  sub_mask = get_subsets(array.size)
  p_set = sub_mask.map do |sub|
    sub_ary = []
    array.zip(sub).each{|s,t| sub_ary << s if t==1}
    sub_ary
  end
end

Benchmark.bm do |x|
  list = [*1..17]
  x.report{ powerset list }
  puts "17 things"
end

puts powerset([1,2,3]).to_s