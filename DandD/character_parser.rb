require 'selenium-webdriver'
require_relative 'agent'
require 'byebug'
require 'json'
require 'csv'

SkillFields = ['Acrobatics', 'Animal Handling', 'Arcana', 'Athletics', 'Deception', 'History', 'Insight', 'Intimidation', 'Investigation', 'Medicine', 'Nature', 'Perception', 'Performance', 'Persuasion', 'Religion', 'Sleight of Hand', 'Stealth', 'Survival']
AbilityFields = %w(strength dexterity constitution intelligence wisdom charisma)
PassivityFields = %w(perception investigation insight)
ItemsFields = %w(armor weapons tools languages)

# TODO:
# BUILD AS AN API, THINK ABOUT STRUCTURING AS JSON
# Perhaps use a Struct.new so that all stats are hashes
# and a Json can be built up.

class Character
  attr_accessor :name, :level, :armor_class, :abilities, :proficiency,
    :skill_proficiency, :walking_speed, :max_xp, :passives, :saving_throws,
    :skills, :items, :attacks

  def initialize(page)
    data = parse_csv

    @page = page
    @abilities = get_texts(AbilityFields, data[:abilities])
    @saving_throws = get_texts(AbilityFields, data[:saving_throws])
    @passives = get_texts(PassivityFields, data[:passives])
    @items = get_texts(ItemsFields, data[:items])

    @name = get_text(data[:name])
    @level = get_text(data[:level])
    @armor_class = get_text(data[:armor_class])
    @proficiency = get_text(data[:proficiency])
    @walking_speed = get_text(data[:walking_speed])
    @max_xp = get_text(data[:max_xp])

    # odd guys
    @skills = get_skills(data)
    @attacks = get_attack(data)

  end

  def get_attack(data) # TODO: how should i format this? CSV style?
    attacks = @page.find_elements(xpath: data[:attacks])
    attacks.map! {|attack| attack.text.gsub("\n",' ')} ; attacks
  end

  def get_skills(data, skill_data={}) # TODO: How will i integrate this into the csv????
    skill_proficiency = @page.find_elements(xpath: data[:skill_proficiency])
    skill_proficiency.map! {|pr| pr.attribute('data-original-title') }

    skills = @page.find_elements(xpath: data[:skills])
    skills.map! {|sk| sk.text.gsub("\n",'') }

    SkillFields.each_with_index do |skill, i|
      skill_data[skill] = {proficiency: skill_proficiency[i], value: skills[i]}
    end

    skill_data
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
  file.inject({}) {|hh, (k, sel)| hh[k.to_sym] = sel ; hh }
end

def process
  csv = parse_csv
  agent = Agent.new(csv[:sebastian])
  yoshimo = Character.new(agent.page)

  puts csv.keys.map {|sym| [sym, yoshimo.send(sym)].to_s}

  agent.quit
end

process
# puts parse_csv
