require 'benchmark'
require 'byebug'

class Sieve
  def initialize(limit)
    @limit = limit
  end

  def sundaram
    limit  = @limit/2 - 2
    ary = []

    (1..limit).each do |j|
      (1..j).each do |i|
        @that = i + j + 2*i*j
        @that > limit ? break : ary << @that
      end
    end

    ary = [*1..limit]-ary
    ary.map{|t|2*t+1}.unshift 2
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
    x.report{ it.primes.count }
    x.report{ it.sundaram.count}
    # puts it.primes == it.sundaram
  end
end

test 10_000

# it = Sieve.new(100)
# puts it.sundaram.to_s

# byebug ; 4