# This update can be performed after each game or each tournament,
# or after any suitable rating period. An example may help clarify.
# Suppose Player A has a rating of 1613, and plays in a five-round tournament.
# 1. He or she loses to a player rated 1609,
# 2. draws with a player rated 1477,
# 3. defeats a player rated 1388,
# 4. defeats a player rated 1586, and
# 5. loses to a player rated 1720.
# 
# The player's actual score is (0 + 0.5 + 1 + 1 + 0) = 2.5.
# The expected score, calculated according to the formula above,
# was (0.506 + 0.686 + 0.785 + 0.539 + 0.351) = 2.867.
# Therefore, the player's new rating is (1613 + 32×(2.5 − 2.867)) = 1601,
# assuming that a K-factor of 32 is used.

# score = 25.5
# gshoa = [847, 822] # 25
# me = [729, 756] # 27
# exp = 0.33642590195870453 # i have a 1/3 chance of winning.
# real = 1

# new_rank = rank + K * (real_score - expected_score)
# 756 = 729 + K * (0.6635740980412954)
# (756 - 729) / 0.6635740980412954  = K

require 'byebug'

def bout player_a, player_b, toss
  score = 1
  if toss.zero? # b wins
    player_b.update(player_a, score)
    player_a.update(player_b, 0)
  else # a wins
    player_a.update(player_b, score)
    player_b.update(player_a, 0)
  end
end

class Player
  attr_accessor :rank
  K = 32 # 42.369 I suspect for 13 x 13

  def initialize(rank=nil)
    @rank = rank || rand(400) + 600
  end

  def expectation(oppenent_rank)
    exponent = (oppenent_rank - rank)/400.0
    1 / (1 + 10 ** exponent)
  end

  def update(opponent, real_score) # perhaps l
    expected_score = expectation(opponent.rank)
    @rank = rank + K * (real_score - expected_score)
  end
end

def tournament(results)
  p1 = Player.new 1500
  p2 = Player.new 1500

  while !results.empty? do
    ranks = [p1, p2].map(&:rank).map(&:floor)
    toss, *results = results
    bout p1, p2, toss
  end
  puts "#{ranks.sort} : avg = #{ranks.inject(:+)/2}"
end

boutResults1 = [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0]
boutResults2 = [1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0]
# boutResults1 = (1..100).map{|i| rand(2)}
# boutResults2 = boutResults1.shuffle

tournament boutResults1
tournament boutResults2
