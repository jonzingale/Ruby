require 'byebug'
def comb ary
	c = ary.count
	pairs = [*1...c-1].inject([]) do |pairs, k|
		pairs += [*0...k].map{|j| [c-k, j]}
	end

	pairs.each do |k, j| ; k += j
		ary[k], ary[j] = ary[j], ary[k] if ary[k] < ary[j]
	end ; ary
end

ary = [10, 5, 12, 2, 4, 3, 8, 11, 7, 1, 9, 6]
puts comb(ary)