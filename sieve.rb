require 'benchmark'
require 'byebug'

class Sieve
  def initialize(limit)
    @limit = limit
    @range = *2..limit
    @range2 = *1..limit
  end

  def sundaram
    ary = []
    @range2.each do |j|
      # 2*(j + j**2) <= n
      (1..j).each do |i| # while this shit or something
        if (cond = i + j + 2*i*j) < @limit
          ary << i + j + 2*i*j
        end
      end
    end

    it = [*1..@limit]-ary
    it.map{|t|2*t+1}.unshift 2
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

# test 10_000
it = Sieve.new(100)
it.sundaram

byebug ; 4