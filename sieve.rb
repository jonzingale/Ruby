require 'benchmark'
require 'byebug'

class Sieve
  def initialize(limit)
    @range = *2..limit
  end

  def primes
    primes = @range
    @range.each do |prime|
      primes.reject! { |num| num % prime == 0 && num != prime }
    end

    primes
  end

  def primes2
    range = @range
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
    x.report{ it.primes.count}
    x.report{ it.primes2.count}
  end
end

test 50_000

# byebug ; 4