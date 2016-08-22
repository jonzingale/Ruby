require 'benchmark'
require 'byebug'

class Sieve
  def initialize(limit)
    @limit = limit
  end

  # Can i,j pairs be Enumerated?
  # not very likely.

  # i_limit is slower than braking
  # i_limit = (limit-j)/(2*j+1)

  def sundaram
    limit  = @limit/2 - 2
    j_limit = (limit-1)/3

    # only odd are needed.
    ary = (2..@limit/2).map{|t| 2*t - 1}

    (1..j_limit).each do |j|
      (1..j).each do |i|
        num = i + j + 2*i*j - 1
        break if num > limit
        ary[num] = nil
      end
    end
    ary.compact.unshift 2
  end

  def primes
    range = *2..@limit
    primes = []

    until range.empty?
      x, *range = range
      range.reject! { |t| t % x == 0 }
      primes << x
    end

    primes
  end
end

def test(num)
  it = Sieve.new(num)
  puts "sundaram primes under #{num}"

  Benchmark.bm do |x|
    # x.report{ it.primes.count }
    x.report{ it.sundaram.count }
  end
end

# user     system      total        real
# 0.340000   0.000000   0.340000 (  0.350320)
test 10**6
