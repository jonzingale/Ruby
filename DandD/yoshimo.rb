require 'selenium-webdriver'
require_relative 'agent'
require 'byebug'
require 'json'
require 'csv'

Yoshimo_Login = 'https://www.dndbeyond.com/profile/Mortekai/characters/3641195'

AbilityFields = %w(strength dexterity constitution intelligence wisdom charisma)
PassivityFields = %w(perception investigation insight)
SavingThrowsFields = %w(strength dexterity constitution intelligence wisdom charisma)

SelStub = "//div[@class='%s']"

# TODO:
# BUILD AS AN API, THINK ABOUT STRUCTURING AS JSON
# Perhaps use a Struct.new so that all stats are hashes
# and a Json can be built up.

class Character
  attr_accessor :name, :level, :armor_class, :abilities, :proficiency,
    :walking_speed, :max_xp, :passives, :saving_throws

  def initialize(page)
    data = parse_csv

    @page = page
    @abilities = get_texts(AbilityFields, data[:abilities])
    @passives = get_texts(PassivityFields, data[:passives])
    @saving_throws = get_texts(SavingThrowsFields, data[:saving_throws])

    @name = get_text(data[:name])
    @level = get_text(data[:level])
    @armor_class = get_text(data[:armor_class])
    @proficiency = get_text(data[:proficiency])
    @walking_speed = get_text(data[:walking_speed])
    @max_xp = get_text(data[:max_xp])

    # byebug
  end

  def get_text(selector)
    @page.find_element(xpath: selector).text.gsub("\n", '')
  end

  def get_texts(fields, selector, data={})
    elems = @page.find_elements(xpath: selector)
    elems.each_with_index {|ps, i| data[fields[i]] = ps.text.gsub("\n",'') }
    data
  end
end

def parse_csv
  file = CSV.read('character.csv')
  file.inject({}) {|hh, (k, sel)| hh[k.to_sym] = SelStub % sel ; hh }
end

def process
  agent = Agent.new
  yoshimo = Character.new(agent.page)

  values = parse_csv.keys
  puts values.map {|sym| [sym, yoshimo.send(sym)].to_s}
  agent.quit
end

process
# puts parse_csv
