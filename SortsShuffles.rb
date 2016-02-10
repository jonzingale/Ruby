# SortsShuffles

def keyshuffle(list) 
	list.map{|k| [Random.new_seed, k]}.sort.map{|ps| ps[1]}
end

def qsort(list)
	list == [] ? [] : 
	(qsort(list.drop(1).select{|d| d <= list[0]})) + [list[0]] + (qsort(list.drop(1).select{|d| d > list[0]}))
end

def qksort(arr)
	if arr.nil? || arr.empty? then [] else
	  piv = arr.pop
	  left, right = arr.partition{|x| x < piv}
	  (qksort(left) << piv) + qksort(right)
	end
end

def rand_qsort(list)
	qsort(keyshuffle(list))
end

def array(n)
	(1..n).inject ([]) {|ary,j| ary << j }
end

# example

# keyshuffle([1,2,3,4,5,6,7,8])
# qsort([5,4,6,3,2,9,1])

# qsort(keyshuffle([1,2,3,4,5,6,7,8]))
