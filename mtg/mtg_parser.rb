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

  def with_mana_cost num
    deck_data.keys.select do |k|
      (deck_data[k]['cmc'] || 0) == num
    end
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

def with_mana_costs deck
  puts "\nMana Cost, Cards and Multiplicity\n"

  (1..10).map do |t|
    cards = deck.with_mana_cost(t)

    cards.map! do |card|
      count = deck.stack.count{|stack| stack == card}
      "#{card}: #{count}"
    end

    puts "#{t}: #{cards}" unless cards.empty?
  end
end

# {0=>26, 1=>7, 2=>14, 3=>8, 4=>2, 5=>4, 6=>3}
art = Deck.new(Decks.deck_of_steel)
useful_data art
with_mana_costs art

byebug ; 4
