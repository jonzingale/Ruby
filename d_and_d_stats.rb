require 'byebug'

OurStats = {'Mortekai' => [1 ,2, 2, 3 ,2 ,4, 13, 14, [2, 8], 6],
            'Roen' => [3, 1, 3, 2, 4, 1, 12, 14, [2, 8], 6],
            'Sam' => [0, 3, 3, 1, 2, 4, 12, 14, [2, 6], 6],
            'Douglas' => [5, 0, 3, 1, 2, 3, 16, 13, [1, 10], 0],
            'Sven' => [2, 4, 0, -1, 2, 0, 15, 12, [2, 10], 4],
            'Everstrong' => [3, 2, 3, 1, 1, 0, 16, 0, [2, 10], 0]
           }

StatsValues = %w(strength dexterity constitution intelligence wisdom
                 charisma ac dc hit_dice spell_bonus)

def hashed_stats name
  values = OurStats[name]
  StatsValues.zip(values).inject({}) { |hash, (k, v)| hash.merge({k=>v}) }
end

byebug

# Calculating Expectations for rolls.
weapons = [ # weapon, onehand, twohand, type, proficiency.
            ['rapier', 8, 8, 'piercing', true], # piercing, bludgeoning, slashing.
            ['quarterstaff', 6, 8, 'bludgeoning', true]
          ]

class Weapon
  attr_reader :weapon, :versatility, :type, :expectation, :proficiency

  def initialize weapon
    @weapon, *@versatility, @type, @proficiency = weapon
    @expectation = get_expectation
  end

  def dieExpect sides
    (1..sides).inject(:+) / sides.to_f
  end

  def get_expectation
    versatility.map { |hand| dieExpect hand }
  end
end

class Mortekai
  # rapier for me: d6 + dexmod + prof = 4.5 + 2 + 2
  # +4 modifier for everyone on to hit.
  # spell save dc: 14 or higher on a d20, ie: 7/20
  attr_reader :expected_damage

  def initialize
    @weapon = Weapon.new ['rapier', 8, 8, 'piercing', true]
    @dex_mod = 2
    @proficiency = 2
    @expected_damage = @weapon.expectation.map {|exp| exp + @dex_mod + @proficiency }
  end
end

me = Mortekai.new

puts me.expected_damage
