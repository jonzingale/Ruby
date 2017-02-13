require 'byebug'

# computes elo rating for two competitors
# when winning makes the winner stronger.

def elo rank_winner, rank_loser, score
  exponent = (rank_loser - rank_winner)/400.0
  rank_diff = 16 * (score - exponent)
  [rank_winner + rank_diff, rank_loser - rank_diff]
end

elo 1613, 1609, 1

# shifting probabilities
# rand > offset, player a wins
def power_diff
  power = 1.08
  offset = 1 / (@t||=2.0)
  toss = rand
  toss > offset ? @t *= power : @t /= power
  # puts "#{toss > offset} : #{1 / (@t||=2.0)}"
  toss > offset
end

def play rank_a, rank_b
  50.times do
    if (a_won = power_diff)
      rank_a, rank_b = elo(rank_a, rank_b, 1)
    else
      rank_b, rank_a = elo(rank_b, rank_a, 1)
    end
    return if [rank_b, rank_a].min < 0
    puts "#{rank_a.floor} #{rank_b.floor} #{a_won}"
  end
end

play 1000, 1000