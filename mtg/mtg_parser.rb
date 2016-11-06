require (File.expand_path('./decks', File.dirname(__FILE__)))
require 'byebug'
require 'json'

include Decks

UsefulMethods = [:some_hand, :cmc_totals, :lands, :creatures]
file = File.read('./allcards.json')
Json = JSON.parse(file)

class Deck
  ColorKeys = {'Blue' => 'U', 'Green' => 'G', 'White' => 'W',
               'Black' => 'B', 'Red' => 'R'}

  attr_reader :deck, :stack, :cmc_totals, :lands, :creatures
  def initialize deck
    @deck = deck
    @stack = mk_stack
    @cmc_totals = cmc_distribution
    @creatures = get_by_type 'Creature'
    @lands = get_by_type 'Land'
  end

  def deck_data
    stack.inject({}) {|hash, k| hash.merge!({k => Json[k]})}
  end

  def get_by_type type
    deck.select { |k, v| deck_data[k]['types'].include?(type) }
  end

  def some_hand
    # hand ordered by mana cost
    hand = stack.shuffle.take 7

    data = hand.map do |key|
      card = Json[key]
      name = card['name']
      cmc = card['cmc'] || 0
      [name, cmc]
    end

    data.sort_by!(&:last)
    data.map { |n, c| "#{n}: #{c}" }
  end

  def mk_stack
    deck.inject([]) { |acc, (k,v)| acc + [k] * v }
  end

  def cmc_distribution
    total_cmc = stack.map do |card|
      cmc = Json[card]['cmc']
      cmc.nil? ? 0 : cmc
    end.sort

    total_cmc.inject({}) do |distr, n|
      count = total_cmc.count { |t| t == n }
      total_cmc.reject! { |c| c == n }
      distr.merge!({n => count})
    end
  end
end

def useful_data deck
  system('clear')
  UsefulMethods.each do |sym|
    puts "\n" ; puts "#{sym.to_s}:"
    puts deck.send(sym)
  end
end

bcc = Deck.new(Decks.blue_creature_control)
cfd = Deck.new(Decks.corwins_fire_deck)

useful_data bcc

# byebug ; 3

# :: {Name => Multiplicity}
# deck = Decks.blue_creature_control
# {0=>21, 1=>14, 2=>13, 3=>10, 5=>2}
# deck = Decks.deck_1
# {0=>21, 1=>14, 2=>17, 3=>11, 5=>4}
# deck = Decks.corwins_fire_deck
# {0=>20, 1=>13, 2=>15, 3=>4, 5=>4}