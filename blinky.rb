# Blinky Lights
class Blinky
	def initialize(width=20,height=20)
		@width, @height = width, height
		@board = rand_board
		@i = 0
	end

	def pretty_print
		@board.each do |row| 
			puts row.join('').gsub(/[01]/, '0' => '   ', '1' => ' * ')
		end
	end

	def rand_board
		(0...@width).map{|i| (0...@height).map{|j| rand 2} }
	end
	
	def cell_at(row,col) ; @board[row][col] ; end
	
	def neighborhood(row,col)
		nears = (-1..1).inject([]){|is,i| is + (-1..1).map{|j| [i,j]} }
		nears = nears.select{|i| i!=[0,0]}
		nears.map{|n,m| cell_at((row+n) % @width, (col+m) % @height) }
	end
		
	def blink(state,neigh)
		sum = neigh.inject :+
		sum == 3 ? 1 : (sum==2&&state==1) ? 1 : 0 
	end
	
	def update(board)
		b = board.take @width
		bs = board.drop @width
		@board = board.empty? ? [] : update(bs).unshift(b)
	end
	
	def go_team
		beers = (0...@width).inject([]) do |is,i| 
			is + (0...@height).map do |j| 
				blink cell_at(i,j), neighborhood(i,j)
			end
		end

		update(beers)
	end

	def run_blinky
		while @i<10**5
			sleep(0.3)
			system("clear")
			pretty_print
			go_team
		end
	end
end

blinky = Blinky.new
blinky.run_blinky
