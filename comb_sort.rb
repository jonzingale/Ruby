class Combable
	def initialize(ary)
		@span = ary.count
		@index = 0
		@ary = ary
	end

	def swap
		high, low = @span - 1 + @index, @index

		if @ary[low] > @ary[high]
			@ary[low], @ary[high] = @ary[high], @ary[low]
		end
	end

	def comb
		if @ary.empty? then []
		elsif @span == 1 then @ary
		elsif @span + @index > @ary.count
			@index = 0
			@span -= 1
			comb
		else
			swap
			@index += 1
			comb
		end
			
	end
end

ary = [10, 5, 12, 2, 4, 3, 8, 11, 7, 1, 9, 6]
combable_ary = Combable.new(ary)

puts combable_ary.comb

