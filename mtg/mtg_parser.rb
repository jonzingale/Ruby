require (File.expand_path('./decks', File.dirname(__FILE__)))
require 'json'
require 'byebug'

include Decks

file = File.read('./allcards.json')
Json = JSON.parse(file)

# deck = Decks.deck_1 # :: {Name => Multiplicity}
deck = Decks.corwins_fire_deck # :: {Name => Multiplicity}

def stack deck
  deck.inject([]) { |acc, (k,v)| acc + [k] * v }.shuffle
end

# ColorKeys = {'U' => 'Blue', 'G' => 'Green', 'W' => 'White',
#              'B' => 'Black', 'R' => 'Red'}

# "manaCost"=>"{3}{U}{U}": 3 colorless, 2 blue.
# cmc is cummulative mana cost.

def deck_data(deck) # :: Hash -> [Hash] ie. a stack.
  deck.keys.map { |k,c| Json[k] }
end

def stack_data(stack) # :: [Keys] -> Hash
  hash = {}
  stack.each {|k| hash.merge!({k => Json[k]})}
  hash
end

def some_hand deck
  stack = stack deck
  total = stack.count
  hand = stack.take 7

  data = hand.map do |key|
    card = Json[key]
    name = card['name']
    cmc = card['cmc'] ? card['cmc'] : 0
    [name, cmc]
  end

  # pretty prints a hand, ordered by mana cost
  puts data.sort_by(&:last).map { |n,c| "#{n}: #{c}" }
end

some_hand deck

byebug ; 3
