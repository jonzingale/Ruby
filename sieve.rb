require 'benchmark'
require 'byebug'

class Sieve
  def initialize(limit)
    @limit = limit
  end

  def sundaram
    ary = []
    limit  = (@limit/2 - 2)#**0.52644

    (1..limit).each do |j|
      (1..j).each do |i|
        if (@that = i + j + 2*i*j) < limit
          ary << @that
        end
      end

      # break if @that > limit # hmm how?
      # must think about how i + j + 2*i*j increments.
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
    puts it.primes.count
  end
end

test 10000

byebug ; 4