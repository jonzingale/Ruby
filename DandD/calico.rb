require 'byebug'
require 'json'
=begin
url : https://www.dndbeyond.com/profile/Mortekai/characters/12821886/json

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


file = File.read('./calico.json')
json = JSON.parse(file)


class Character
  attr_reader :file, :name, :spells, :actions

  def initialize file
    @file = JSON.parse(file)['character']
    @name = @file['name']
    @level = get_level
    @wisdom = get_wisdom
    @actions = get_actions
  end

  def get_wisdom
    
  end

  def get_level
    file['classes'][0]['level']
  end

  def get_actions
    file['actions']['class'].map do |act|
      limiteduse = act['limitedUse']['maxUses']
      actName = act['name']
      snippet = act['snippet']
      "%s: %s \n\n" % [actName, snippet]
      byebug
    end
  end

end

calico = Character.new(file)
puts calico.actions


byebug ; 4