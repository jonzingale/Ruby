require (File.expand_path('./decks', File.dirname(__FILE__)))
require 'byebug'
require 'json'

include Decks

UsefulMethods = [:some_hand, :cmc_totals, :lands, :creatures,
                 :sorceries, :instants, :enchantments, :artifacts,
                 :planeswalkers]

file = File.read('./allcards.json')
Json = JSON.parse(file)

class Deck
  Types = [:Land, :Artifact, :Enchantment, :Sorcery, :Instant, :Creature,
           :Planeswalker]

  ColorKeys = {'Blue' => 'U', 'Green' => 'G', 'White' => 'W',
               'Black' => 'B', 'Red' => 'R'}

  attr_reader :deck, :stack, :cmc_totals, :lands, :creatures, :artifacts,
              :sorceries, :instants, :enchantments, :planeswalkers

  def initialize deck
    @deck = deck
    @stack = mk_stack
    @cmc_totals = cmc_distribution
    @planeswalkers = get_by_type 'Planeswalker'
    @enchantments = get_by_type 'Enchantment'
    @creatures = get_by_type 'Creature'
    @artifacts = get_by_type 'Artifact'
    @sorceries = get_by_type 'Sorcery'
    @instants = get_by_type 'Instant'
    @lands = get_by_type 'Land'
  end

  def deck_data
    stack.inject({}) { |hash, k| hash.merge!({k => Json[k]}) }
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
    end.sort ; distr = {}

    until total_cmc.empty?
      head = total_cmc.first
      tally = total_cmc.count {|t| t == head }
      distr.merge!({head => tally})
      total_cmc.reject! {|c| c == head }
    end ; distr
  end
end

def useful_data deck
  system('clear')
  UsefulMethods.each do |sym|
    datum = deck.send(sym)
    totals = datum.values.inject(:+) if datum.is_a?(Hash)
    puts "\n" ; puts "#{sym.to_s}: #{totals}"
    puts datum
  end
end

bcc = Deck.new(Decks.blue_creature_control)
bcc2 = Deck.new(Decks.blue_creature_control_redux)
cfd = Deck.new(Decks.corwins_fire_deck)
cfz = Deck.new(Decks.cards_from_zeke)
deck_1 = Deck.new(Decks.deck_1)

useful_data bcc2

# byebug ; 3

# :: {Name => Multiplicity}
# blue_creature_control_redux
# {0=>22, 1=>12, 2=>16, 3=>8, 5=>2, 8=>1}
# blue_creature_control
# {0=>21, 1=>14, 2=>13, 3=>10, 4=>3, 5=>2}
# deck_1
# {0=>21, 1=>14, 2=>17, 3=>11, 4=>3, 5=>4}
# corwins_fire_deck
# {0=>20, 1=>13, 2=>15, 3=>4, 4=>4, 5=>4}