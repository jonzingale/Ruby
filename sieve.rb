require 'benchmark'
require 'byebug'

class Sieve
  def initialize(limit)
    @limit = limit
  end

# binary tree search
# enumerable class docs

  # Computing with i_limit is slower
  # than just breaking when limit is reached.
  # i_limit = (limit-j)/(2*j+1)
  def sundaram # 10**8 max
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
  Benchmark.bm do |x|
    puts 'primes'
    x.report{ it.primes.count }
    puts 'sundaram'
    x.report{ it.sundaram.count }
  end
  puts 'primes == sundaram: ' \
       "#{it.primes.count == it.sundaram.count}"
end

test 10**5
