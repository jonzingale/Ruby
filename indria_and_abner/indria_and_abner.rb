require 'byebug'

class Indria
  attr_accessor :lists
  def initialize(error=0.01, resource=10)
    @lists = []
    write_list
  end

  def write_list
    # consider copying something canonical with some error
    @lists += [*1..resource].map { rand }
  end
end

class Abner
  attr_accessor :buckets, :bucketCounts

  def initialize(error=0.01, resource=5)
    @buckets = []
    @bucketCounts = []
  end

  # compare against representative from each bucket
  # if not any, then new bucket.
  def receive_list(fromIndria)
    if @buckets.empty?
      @buckets << [fromIndria]
      @bucketCounts << 1
    else
       # each index plays horrible game.
       # if None has to trigger, but how?
      @buckets.each_with_index do |bucket, idx|
        r = (rand * @bucketCounts[idx]).floor
        rep = bucket[r]

        sameEnough = compare(rep, fromIndria)

        if sameEnough
          byebug
          @buckets[idx] << fromIndria
          @bucketCounts[idx] += 1
        else
          @buckets << [fromIndria]
          @bucketCounts << 1
        end
      end
    end
  end

  def compare(rep, fromIndria)
    # perfect match
    fromIndria.zip(rep).all? { |i, r| i == r }
  end
end

abner = Abner.new
abner.receive_list([*1..4])
print abner.buckets
abner.receive_list([*1..4])
print abner.buckets
abner.receive_list([2,3,2,1])
# print abner.buckets
# print abner.bucketCounts
# abner.receive_list([1])
# print abner.buckets
# print abner.bucketCounts
byebug ; 2