require 'byebug'

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
