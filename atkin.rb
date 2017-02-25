require 'benchmark'

class PrimesAtkin
  FLIPPER1 = [1, 13, 17, 29, 37, 41, 49, 53].freeze
  FLIPPER2 = [7, 19, 31, 43].freeze
  FLIPPER3 = [11, 23, 47, 59].freeze
  WHEEL_HITS = (FLIPPER1 + FLIPPER2 + FLIPPER3).freeze

  attr_accessor :limit

  def initialize(l)
    @limit = l
    @sieve1 = init_sieve
    @sieve2 = init_sieve
    @sieve3 = init_sieve
    @results = [2,3,5]
  end

  def init_sieve
    l = (limit / 60).ceil
    (0..l).each_with_object({}) do |w, sieve|
      WHEEL_HITS.each do |x|
        sieve[60 * w + x] = false
      end
    end
  end

  def flipper1
    y_limit = Math.sqrt(limit).ceil
    x_limit = y_limit*4
    (1..y_limit).step(2) do |y|
      (1..x_limit).step(1) do |x|
        n = (4*x*x + y*y)
        break if n > limit
        if FLIPPER1.include?(n % 60)
          @sieve1[n] = !@sieve1[n]
        end
      end
    end
  end

  def flipper2
    y_limit = Math.sqrt(limit).ceil
    x_limit = y_limit*3
    (2..y_limit).step(2) do |y|
      (1..x_limit).step(2) do |x|
        n = (3*x*x + y*y)
        break if n > limit
        if FLIPPER2.include?(n % 60)
          @sieve2[n] = !@sieve2[n]
        end
      end
    end
  end

  def flipper3
    y_limit = (0.5 * (Math.sqrt(3+2*limit) - 3)).ceil
    (0..y_limit).each do |y|
      x_limit = Math.sqrt((limit + y*y) / 3).ceil
      ((y+1)..x_limit).each do |x|
        next if (x + y).even?
        n = (3*x*x - y*y)
        break if n > limit
        if FLIPPER3.include?(n % 60)
          @sieve3[n] = !@sieve3[n]
        end
      end
    end
  end

  def merge_sieves
    @sieve1.each_key do |k|
      @sieve1[k] = @sieve1[k] ^ @sieve2[k] ^ @sieve3[k]
    end
  end

  def mark_squares
    @sieve1.each_key do |k|
      next unless @sieve1[k]
      break if k > limit
      x = k * k
      (2..limit).each do |i|
        n = x * i
        break if n > limit
        @sieve1[n] = false unless @sieve1[n].nil?
      end
      @results << k
    end
  end

  def primes
    Benchmark.bm do |x|
      # x.report('flipper_threads') do
      #   @threads = []
      #   @threads << Thread.new { flipper1 }
      #   @threads << Thread.new { flipper2 }
      #   @threads << Thread.new { flipper3 }
      #   @threads.each { |thr| thr.join }
      # end
      x.report('flipper1') { flipper1 }
      x.report('flipper2') { flipper2 }
      x.report('flipper3') { flipper3 }
      x.report('merge_sieves') { merge_sieves }
      x.report('mark_squares') { mark_squares }
    end

    @results
  end
end

puts PrimesAtkin.new(10_000_000).primes.sort[-10,10].inspect
