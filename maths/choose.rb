def pascal_long(i,num=[1])
	if num.count <= i
		ary = num.unshift(0)
		mum = ary.map.with_index do |k,j|
			right = ary[j+1].nil? ? 0 : ary[j+1]
			ary[j] + right
		end
		pascal_long(i,mum)
	else
		num
	end
end

def factorial_run(n,k)
	k > 0 ? n * factorial_run(n-1,k-1) : 1 
end

def choose(n,k)
	factorial_run(n,k) / factorial_run(k,k)
end

def pascal(num)
	(0..num).map{|k| choose(num,k) }
end

puts pascal_long(4).to_s
puts pascal(4).to_s
