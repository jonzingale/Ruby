require 'byebug'

class Stringy
  attr_reader :str, :ary

  def initialize
    @top = 255
    @ary = [1]
  end

  def put it
    puts "%08d" % it.to_s(2)
  end

  def modify str, n
    if n == 0
      str ^ 3
    elsif n == 7
      str ^ 192
    else
      val = 7 * 2 ** (n-1)
      str ^ val
    end
  end

  def accum
    while @ary.length < @top
      @ary.each do |str|
        (0..7).each do |n|
          val = modify str, n
          unless @ary.include?(val)
            @ary << val
            puts val
          end
        end
      end
    end
  end
end

boundary = "%08d" % (255 ^ 3).to_s(2)
it = Stringy.new
it.accum

byebug ; 3