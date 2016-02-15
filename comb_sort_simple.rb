def swap(ary, j, k)
	ary[k], ary[j] = ary[j], ary[k]
end

def comb ary
	[*1..ary.count].each do |k|
		[*1..ary.count-k].each{|j| swap(ary, j, k) if ary[k] < ary[j]}
	end
end

ary = [10, 5, 12, 2, 4, 3, 8, 11, 7, 1, 9, 6]

puts comb ary


