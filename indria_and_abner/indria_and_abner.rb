require 'byebug'

# TODO:
# 1. implement error
# 2. visualize stability/change

class Indria
  attr_accessor :list, :resource
  def initialize(resource=4, error=0.01)
    @symbols = 3
    @list = []
    @resource = resource
    write_list
  end

  def write_list
    # consider copying something canonical with some error
    @list = [*0...@resource].map { rand(@symbols) } # :: Int
  end
end

class Abner
  attr_accessor :buckets, :bucketCounts, :bucketsCount

  def initialize(resource=4, indria_resource=4, error=0.01)
    @buckets = []
    @bucketCounts = []
    @bucketsCount = 0
    @resource = resource
    @indria_resource = indria_resource
  end

  # compare against representative from each bucket
  # if not any, then new bucket.
  def receive_list(fromIndria)
    if @buckets.empty?
      # make new bucket
      @buckets << [fromIndria]
      @bucketCounts << 1
      @bucketsCount += 1
    else
      # get representatives
      reps = []
      @buckets.each_with_index do |bucket, idx|
        rIdx = rand(@bucketCounts[idx])
        reps << bucket[rIdx]
      end

      mIdx = reps.find_index { |rep| compare(rep, fromIndria) }

      if mIdx
        # for each representative, compare and store in @buckets accordingly
        @buckets[mIdx] << fromIndria
        @bucketCounts[mIdx] += 1
      else
        # make new bucket
        @buckets << [fromIndria]
        @bucketCounts << 1
        @bucketsCount += 1
      end
    end
  end

  def internal_audit
    # get list from some bucket
    rIdx = rand(@bucketsCount)
    # remove from that bucket
    list = @buckets[rIdx].shift
    @bucketCounts[rIdx] -= 1
    # clean up buckets
    if @buckets[rIdx].empty?
      @buckets.delete_at(rIdx)
      @bucketCounts.delete_at(rIdx)
      @bucketsCount -= 1
    end
    # reclassify list
    receive_list(list)
  end

  def compare(rep, fromIndria)
    # perfect match, MUST BE SAME SIZE!
    # fromIndria.zip(rep).all? { |i, r| i == r }

    # abner verifies only some of what indria offers
    rIds = (0...@resource).map { rand(@indria_resource) } # NOTE: with replacement
    rIds.all? { |id| fromIndria[id] == rep[id] }
  end
end

def show_sorted_counts(abner)
  print "\n#{abner.bucketCounts.sort}\n"
end

def show_buckets(abner)
  abner.buckets.each { |b| print "#{b}\n" }
end

def main
  indria = Indria.new(10) # more resource than abner
  abner = Abner.new(4, indria.resource)

  n = 0 ; while (n < 7000)
    indria.write_list
    abner.receive_list(indria.list) # compare against indria and classify.
    abner.internal_audit # compare against self, reclassify if need be.
    n += 1
  end
  # show_buckets(abner)
  show_sorted_counts(abner)
end

main
