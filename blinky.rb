class Blinky
	NEARS = [-1,0,1].product([-1,0,1]).reject{|t| t==[0,0]}

	attr_accessor :board
	def initialize(width=20, height=20)
		@width, @height = width, height
		@board = rand_board
		@next_board = @board.map(&:dup)
		@i = 0
	end

	def glider
		board = (0...@width).map{|i| (0...@height).map{|j| 0} }
		board[5][11] = 1 
		board[6][10] = 1 
		board[7][10] = 1
		board[7][11] = 1
		board[7][12] = 1
		board
	end

	def pretty_print
		@board.each do |row|
			puts row.join('').gsub(/[01]/, '0' => '   ', '1' => ' * ')
		end
	end

	def rand_board
		(0...@width).map{|i| (0...@height).map{|j| rand 2} }
	end

	def cell_at(row, col) ; @board[row][col] ; end

	def neighborhood(row, col)
		NEARS.map do |j, i|
			cell_at((row + j) % @height, (col + i) % @width)
		end
	end

	# generalize this
	def blink state, neigh
		sum = neigh.inject :+
		sum == 3 ? 1 : (sum == 2 && state == 1) ? 1 : 0
	end

	def go_team
		(0...@width).each do |i| # col
			(0...@height).each do |j| # row
				cell = @board[j][i]
				neigh = neighborhood(j,i)
				@next_board[j][i] = blink cell, neigh
			end
		end

		@board = @next_board.map(&:dup)
	end

  # 1.860000   0.700000   4.550000 (  6.127506) for 10**3
	def run_blinky
		while @i<10**3
			@i += 1
			# sleep(0.3)
			system("clear")
			pretty_print
			go_team
		end
	end
end

# for testing.
# require 'Benchmark'
# require 'byebug'

# def test
# 	blinky = Blinky.new

# 	Benchmark.bm do |x|
# 		x.report{ blinky.run_blinky }
# 	end
# end

# test