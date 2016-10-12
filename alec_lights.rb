require 'byebug'

class Stringy
  attr_reader :str, :ary

  def initialize
    @ary = [255]
    reset
  end

  def reset
    @str = 255 ; put
  end

  def put
    puts "%08d" % @str.to_s(2)
  end

  def modify str, n
    if n == 0
      str ^ 3
    elsif n == 7
      str ^ 192
    else
      pp = 2 ** (n+1)
      nn = 2 ** n
      mm = 2 ** (n-1)
      str^(pp + nn + mm)
    end
  end

  def accum
    @i = 0
    while @ary.length < 255
      @ary.each do |str|
        (0..7).each do |n|
          val = modify str, n
          (@ary << val ; @i+=1) unless @ary.include?(val)
        end
      end
puts @i
    end
  end
end

boundary = "%08d" % (255 ^ 3).to_s(2)
it = Stringy.new
it.accum

byebug ; 3