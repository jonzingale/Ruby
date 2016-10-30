require (File.expand_path('./decks', File.dirname(__FILE__)))
require 'json'
require 'byebug'

include Decks

file = File.read('./allcards.json')
json = JSON.parse(file)

deck = Decks.deck_1

ColorKeys = {'U' => 'Blue', 'G' => 'Green', 'W' => 'White',
             'B' => 'Black', 'R' => 'Red'}

AirElemental = json.first
EmpyrealVoyager = json['Empyreal Voyager']

pure_blue_cards = json.select{|k,v| json[k]['colorIdentity']==['U']}

blue_cards = json.select do |k,v|
  unless (id = json[k]['colorIdentity']).nil?
    id.include? 'U'
  end
end

# Island
# {"layout"=>"normal", "name"=>"Island", "type"=>"Basic Land — Island",
#  "supertypes"=>["Basic"], "types"=>["Land"], "subtypes"=>["Island"],
#  "imageName"=>"island", "colorIdentity"=>["U"]}

# Aether Hub
# {"layout"=>"normal", "name"=>"Aether Hub", "type"=>"Land",
#  "types"=>["Land"], "text"=>"When Aether Hub enters the battlefield,
#   you get {E} (an energy counter).\n{T}: Add {C} to your mana pool.\n{T},
#   Pay {E}: Add one mana of any color to your mana pool.", 
#  "imageName"=>"aether hub"}

# Air Elemental
# {"layout"=>"normal", "name"=>"Air Elemental", "manaCost"=>"{3}{U}{U}",
   # "cmc"=>5, "colors"=>["Blue"], "type"=>"Creature — Elemental",
   # "types"=>["Creature"], "subtypes"=>["Elemental"], "text"=>"Flying",
   # "power"=>"4", "toughness"=>"4", "imageName"=>"air elemental",
   # "colorIdentity"=>["U"]}


# "manaCost"=>"{3}{U}{U}"
# 3 colorless, 2 blue.
# cmc is cummulative mana cost.

byebug ; 3
