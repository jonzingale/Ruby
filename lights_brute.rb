# There are lots of assumptions about the board being 8 bits, this can be
# abstracted in the LightBoard class.
# Also, this file needs to be 100 lines.

class LightBoard
  WINS = [0b00000000, 0b11111111]

  attr_accessor :state, :history

  def initialize (s, h=[])
    @state = s
    @history = h
  end

  def to_i
    state.to_i
  end

  def win?
    WINS.include? state
  end

  def <=> light
    self.to_i <=> light.to_i
  end

  def == light
    self.to_i == light.to_i
  end

  def to_s
    (history + [self]).map(&:state_to_s).join(" -> ")
  end

  def state_to_s
    "%08b" % state
  end

  def flip n
    # mask 0b111 shifted and bounded before xor
    new_state = state ^ ((0b111 << n-1) % 0b100000000)
    LightBoard.new(new_state, history + [self])
  end
end

class Tester
  BAILOUT = 1000 # Because I don't like infinite loops

  attr_accessor :seed, :lights

  def initialize (s)
    @seed = LightBoard.new(s)
    @lights = [seed]
    test_all
  end

  def to_s
    lights.map(&:to_s).join("\n")
  end

  def sorted_to_s
    lights.sort.map(&:to_s).join("\n")
  end

  def test (l)
    8.times do |i|
      flipped = l.flip(i)
      @lights << flipped unless lights.include? flipped
    end
  end

  def test_all
    light_count = c = 0
    while light_count < lights.count && c < BAILOUT
      c += 1
      light_count = lights.count
      light_count.times do |i| # can't use each because we're modifying it
        test lights[i]
      end
      raise 'Bailout hit' if c == BAILOUT
    end
  end

  def wins
    lights.select(&:win?)
  end

  def win?
    lights.any?(&:win?)
  end
end

wins = []
LightBoard::WINS.max.times do |i|
  print '.'
  t = Tester.new(i)
  wins << t.wins if t.win?
end

puts wins