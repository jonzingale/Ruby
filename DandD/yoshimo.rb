require 'selenium-webdriver'
require_relative 'agent'
require 'byebug'
require 'json'
require 'csv'

DndStub = 'https://www.dndbeyond.com/profile/Mortekai/characters/'
Yoshimo_Login = DndStub + '3641195'

SkillFields = ['Acrobatics', 'Animal Handling', 'Arcana', 'Athletics', 'Deception', 'History', 'Insight', 'Intimidation', 'Investigation', 'Medicine', 'Nature', 'Perception', 'Performance', 'Persuasion', 'Religion', 'Sleight of Hand', 'Stealth', 'Survival']
AbilityFields = %w(strength dexterity constitution intelligence wisdom charisma)
PassivityFields = %w(perception investigation insight)
ItemsFields = %w(armor weapons tools languages)

# ProficiencySel = '//div[@class="ct-skills__list"]/div["ct-skills__item"]/div[@class="ct-skills__col--proficiency"]/span'
# SkillSel = '//div[@class="ct-skills__list"]/div["ct-skills__item"]/div[@class="ct-skills__col--modifier"]'

# TODO:
# BUILD AS AN API, THINK ABOUT STRUCTURING AS JSON
# Perhaps use a Struct.new so that all stats are hashes
# and a Json can be built up.

class Character
  attr_accessor :name, :level, :armor_class, :abilities, :proficiency,
    :skill_proficiency, :walking_speed, :max_xp, :passives, :saving_throws,
    :skills, :items

  def initialize(page)
    data = parse_csv

    @page = page
    # @abilities = get_texts(AbilityFields, data[:abilities])
    # @saving_throws = get_texts(AbilityFields, data[:saving_throws])
    # @passives = get_texts(PassivityFields, data[:passives])
    # @items = get_texts(ItemsFields, data[:items])

    # @name = get_text(data[:name])
    # @level = get_text(data[:level])
    # @armor_class = get_text(data[:armor_class])
    # @proficiency = get_text(data[:proficiency])
    # @walking_speed = get_text(data[:walking_speed])
    # @max_xp = get_text(data[:max_xp])

    @attack = get_attack

    # @skills = get_skills # odd guy out
  end

  def get_attack # TODO: how should i format this? CSV style?
    byebug
    attacks = @page.find_elements(xpath: "//div[@class='ct-attack-table__content']/div")
    attacks.map {|attack| attack.text.gsub("\n",' ')}
    # attacks.map do |attack|
    #   attack.text.gsub("\n",' ')
    # end
  end

  def get_skills # TODO: How will i integrate this into the csv????
    sels = parse_csv
    skill_proficiency = @page.find_elements(xpath: sels[:skill_proficiency])
    skill_proficiency.map! {|pr| pr.attribute('data-original-title') }

    skills = @page.find_elements(xpath: sels[:skills])
    skills.map! {|sk| sk.text.gsub("\n",'') }

    data = {} ; SkillFields.each_with_index do |skill, i|
      data[skill] = {proficiency: skill_proficiency[i], value: skills[i]}
    end ; data
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
  agent = Agent.new
  yoshimo = Character.new(agent.page)

  values = parse_csv.keys
  puts values.map {|sym| [sym, yoshimo.send(sym)].to_s}
  puts yoshimo.skills
  agent.quit
end

process
# puts parse_csv
