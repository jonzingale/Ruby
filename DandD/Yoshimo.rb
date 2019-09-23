require 'byebug'
require 'json'
=begin
url : https://www.dndbeyond.com/profile/Mortekai/characters/3641195/json

THE USEFUL DATA:
https://www.dndbeyond.com/api/config/json?v=2.5.1
will need to sign in with username and password
consider curl and/or mechanize. Zeke thinks it
should be possible.


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


file = File.read('./Yoshimo.json')
json = JSON.parse(file)


class Deck
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
    @actions = get_actions
  end

  def get_actions
    deck['actions']['class'].map do |ac|
      actName = ac['name']
      snippet = ac['snippet']
      "%s: %s \n" % [actName, snippet]
    end
  end

end

yoshi = Deck.new(file)
puts yoshi.actions


byebug ; 4