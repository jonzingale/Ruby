class Blinky
  NEARS = [-1,0,1].product([-1,0,1]).reject{|t| t==[0,0]}

  attr_accessor :board
  def initialize(width=20, height=20)
    @width, @height = width, height
    @ary_size = width * height
    @board = rand_board
    @next_board = []
    @i = 0
  end

  def rand_board ; (0...@ary_size).map{ rand 2 } ; end

  def pretty_print
    system("clear")
    ary = @board.dup

    until ary.empty? 
      line = ary.shift(@width).join('')
      puts line.gsub(/[01]/, '0' => '   ', '1' => ' * ')
    end
  end

  def neighborhood val
    row, col = val.divmod @width 

    NEARS.map do |j, i|
      rr = (row + j) % @height
      cc = (col + i) % @width
      @board[rr * @width +  cc]
    end
  end

  # generalize this
  def blink state, neigh
    sum = neigh.inject :+
    sum == 3 ? 1 : (sum == 2 && state == 1) ? 1 : 0
  end

  def update
    @ary_size.times do |val|
      cell = @board[val]
      neigh = neighborhood val
      @next_board[val] = blink cell, neigh
    end

    @board = @next_board.dup
  end

  def run_blinky
    while @i<10**3
      @i += 1
      # sleep(0.3)
      pretty_print
      update
    end
  end
end

# for testing.
require 'Benchmark'
require 'byebug'

def test
  blinky = Blinky.new

  Benchmark.bm do |x|
    x.report{ blinky.run_blinky }
  end
end

test