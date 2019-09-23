require 'byebug'
require 'json'
=begin
url : https://www.dndbeyond.com/profile/Mortekai/characters/3790895/json

puts json['character']['notes']['personalPossessions']

json['character']['inventory'].map{|j| j}

character
  name
  notes
  inventory
  currencies
  classes
  feats
  spells
  actions
  modifiers
  classSpells
=end
# UsefulMethods = [:character]
UsefulMethods = [:name ,:background ,:notes , :inventory ,:currencies ,
                 :classes,:feats ,:spells ,:actions ,:modifiers ,:classSpells]


file = File.read('./Mortekai.json')
json = JSON.parse(file)


class Deck
  Types = [:Land, :Artifact, :Enchantment, :Sorcery, :Instant, :Creature,
           :Planeswalker]

  ColorKeys = {'Blue' => 'U', 'Green' => 'G', 'White' => 'W',
               'Black' => 'B', 'Red' => 'R'}

  attr_reader :deck, :name, :spells, :actions

=begin
  id
  name
  level
  duration
  range
  asPartOfWeaponAttack
  description
  concentration
  ritual
  rangeArea
  damageEffect
  saveDcAbilityId
  healing
  healingDice
  tempHpDice
  attackType
  canCastAtHigherLevel

  requiresSavingThrow
  requiresAttackRoll
  atHigherLevels
  modifiers
  conditions
  tags
  castingTimeDescription
=end
  def initialize deck
    @deck = JSON.parse(deck)['character']
    @name = @deck['name']
    @spells = get_spells
    @actions = get_actions
  end

  def get_actions
    deck['actions']['class'].map do |ac|
      actName = ac['name']
      snippet = ac['snippet']
      "%s: %s \n" % [actName, snippet]
    end
  end

  def get_spells
    deck['classSpells'][1]['spells'].map do |spell|
      sp = spell['definition']

      charName = sp['name']
      desc = sp['description']
      conc = sp['concentration']
      range = sp['rangeValue']
      level = sp['level']

      dur = sp['duration']['durationInterval']
      unit = sp['duration']['durationUnit']
      durType = sp['duration']['durationType']
      duration = "%i %s %s" % [dur||0, unit, durType]

      ritual = sp['ritual'] ? "Ritual" : ""
      tags = sp['tags'].join(' ')

      fm1 = "\n%s, level %s: %s" % [charName, level.to_s, duration]
      fm2 = " %s, %s\n %s\n" % [ritual, tags, desc]
      fm1 + fm2
    end
  end
end

morte = Deck.new(file)

# puts morte.spells
puts morte.actions


byebug ; 4