TwoFiftySix = 0b100000000.freeze
Seven = 0b111.freeze

class Stringy
  attr_reader :ary

  def initialize
    @ary = [255]
    accum
  end

  def put
    puts ary.sort.to_s
  end

  def accum
    while ary.length < TwoFiftySix/2
      ary.each do |bits|
        7.times do |n|
          val = bits ^ (Seven << n-1) % TwoFiftySix
          ary << val unless ary.include?(val)
        end
      end
    end
  end
end

Stringy.new.put