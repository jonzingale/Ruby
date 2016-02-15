def comb ary
	c = ary.count
	[*1...c-1].each do |k|
		[*0...k].each do |j| ; hi = c - k + j
			ary[hi], ary[j] = ary[j], ary[hi] if ary[hi] < ary[j]
		end
	end ; ary
end

ary = [10, 5, 12, 2, 4, 3, 8, 11, 7, 1, 9, 6]
puts comb(ary)