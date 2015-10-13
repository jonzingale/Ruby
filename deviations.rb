# How many pages of randomized rates
# must I scrape before my chances are
# pretty good that I have the lowest
# rate?

require 'byebug'
# https://en.wikipedia.org/wiki/T-statistic
# https://en.wikipedia.org/wiki/Sample_maximum_and_minimum
# https://en.wikipedia.org/wiki/Normality_test
# https://en.wikipedia.org/wiki/Secretary_problem

class Stats
	attr_reader :distr, :with_counts, :count, :mean, :var, :low, :sig
	def initialize rates
		@distr = rates
		@with_counts = counts_recursively rates.sort
		@count = rates.count.to_f
		@mean = @distr.inject(0,:+)/@count
		@var = @distr.map{|r| r**2}.inject(0,:+)/@count
		@sig = (@var - @mean**2)**0.5
		@low = rates.min
	end

	def near_center? stat
		dev_ball = @sig * 2
		stat_ball = (@mean - stat).abs
		stat_ball < dev_ball
	end

	def rates_to_uniq ; @count / @distr.uniq.count ; end

	def counts_recursively(ary)
		if ary.empty? then [] else
			as, bs = ary.partition{ |t| t == ary.first }
			counts_recursively(bs).unshift([as.first, as.count])
		end
	end

	# make this non integer ?
	def sigs_from_center(low_stat,i=0)
		cond = (@mean - low_stat).abs < @sig * i
		cond ? i : sigs_from_center(low_stat,i+1)
	end

	# reject n/e, then grab next lowest thus far.
	# really i should likely uniq in there somehow
	# and figure out a large enough data set to have
	# a reasonable sample set.
	def secretary
		low_reject = distr.take(count/2.718281828).min
		considered = distr.drop(count/2.718281828)
		considered.detect{|good| good <= low_reject}
	end

	def get_data
		# "distribution:\n#{@distr}\n" \
		"counts:\n#{@with_counts}\n" \
		"mean: #{@mean}, " \
		"low sigs from mean: #{self.sigs_from_center @low}\n"
	end

end

rates = [210.0, 155.0, 110.0, 155.0, 210.0, 150.0, 170.0, 155.0, 150.0, 150.0]
stats = Stats.new rates

americas_best = [84.0, 84.0, 84.0, 105.0, 105.0, 105.0]
best =  Stats.new americas_best
# low = 84.0

latham_rates = [189.00,189.00,189.00,209.00,289.00,289.00,289.00]
latham = Stats.new latham_rates
# price = 189.00

vagabond = [109.99, 109.99, 119.99, 119.99, 129.99, 139.99, 149.99, 98.99, 98.99, 107.99, 107.99, 116.99, 125.99, 134.99, 98.99, 98.99, 107.99, 107.99, 116.99, 125.99, 134.99, 149.99, 149.99, 159.99, 159.99, 169.99, 179.99, 189.99, 189.99, 189.99, 199.99, 199.99, 209.99, 219.99, 229.99, 98.99, 98.99, 107.99, 107.99, 116.99, 125.99, 134.99]
vagabond = Stats.new vagabond

vagabond.secretary

# low is how many sigs from center?
# system('clear')
puts stats.get_data
puts best.get_data
puts latham.get_data

byebug ; 4