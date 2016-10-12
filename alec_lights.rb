require 'byebug'

class Stringy
  attr_reader :ary

  def initialize
    @ary = [255]
  end

  def put it
    puts "%08d" % it.to_s(2)
  end

  def modify bits, n
    # if n == 0
    #   bits ^ 3
    # elsif n == 7
    #   bits ^ 192
    # else
    #   val = 7 * 2 ** (n-1)
    #   bits ^ val
    # end

    # mask 0b111 shifted and bounded before xor
    # bits ^ (7 << n-1) % 256
    bits ^ (0b111 << n-1) % 0b100000000
  end

  def accum
    while ary.length < 255/2
      @ary.each do |bits|
        (0..7).each do |n|
          val = modify bits, n
          @ary << val unless @ary.include?(val)
        end
      end
    end ; puts @ary.sort.to_s
  end
end

system('clear')
it = Stringy.new
it.accum