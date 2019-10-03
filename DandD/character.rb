require 'selenium-webdriver'
require_relative 'agent'
require 'byebug'
require 'json'
require 'csv'

DndStub = 'https://www.dndbeyond.com/profile/Mortekai/characters/'
SkillFields = ['Acrobatics', 'Animal Handling', 'Arcana', 'Athletics', 'Deception', 'History', 'Insight', 'Intimidation', 'Investigation', 'Medicine', 'Nature', 'Perception', 'Performance', 'Persuasion', 'Religion', 'Sleight of Hand', 'Stealth', 'Survival']
AbilityFields = %w(strength dexterity constitution intelligence wisdom charisma)
PassivityFields = %w(perception investigation insight)
ItemsFields = %w(armor weapons tools languages)

Spells_Tab_Sel = "//div[@class='ct-primary-box__tab--spells ct-tab-list__nav-item']"
Spells_By_Level_SEl = "//div[@class='ct-tab-options__content ']/div[@class='ct-content-group']"

# TODO:
# BUILD AS AN API, THINK ABOUT STRUCTURING AS JSON
# Perhaps use a Struct.new so that all stats are hashes
# and a Json can be built up.

class Character
  attr_accessor :name, :level, :armor_class, :abilities, :proficiency,
    :skill_proficiency, :walking_speed, :max_xp, :passives, :saving_throws,
    :skills, :items, :attacks

  def initialize(character)
    character_id = parse_csv('character_ids.csv')[character]
    @agent = Agent.new(DndStub + character_id)
    @page = @agent.page

    @csv = parse_csv('character.csv')
    @abilities = get_texts(AbilityFields, @csv[:abilities])
    @saving_throws = get_texts(AbilityFields, @csv[:saving_throws])
    @passives = get_texts(PassivityFields, @csv[:passives])
    @items = get_texts(ItemsFields, @csv[:items])

    @name = get_text(@csv[:name])
    @level = get_text(@csv[:level])
    @armor_class = get_text(@csv[:armor_class])
    @proficiency = get_text(@csv[:proficiency])
    @walking_speed = get_text(@csv[:walking_speed])
    @max_xp = get_text(@csv[:max_xp])

    # odd guys
    @skills = get_skills
    @attacks = get_attack

    # modifies window
    @spells = get_spells
    display_spells

    @agent.quit
  end

  def display
    puts @csv.keys.map {|sym| [sym, self.send(sym)].to_s}
  end

  def display_spells
    @spells.each do |k, v|
      puts "\n#{k}\n"
      v.each {|spell| puts spell}
    end
  end

  def get_spells # TODO: CLEAN UP THIS CODE
    begin
      spell_tab = @page.find_element(xpath: Spells_Tab_Sel)
      spell_tab.click
      spells_by_level = @page.find_elements(xpath: Spells_By_Level_SEl)

      all_spells = spells_by_level.inject({}) do |accum, elem|
        header_path = "\div[@class='ct-content-group__header']"
        spell_level = elem.find_element(xpath: header_path).text.split("\n")[0]

        spell_sel = "div[@class='ct-content-group__content']//div[@class=' ct-spells-spell']"
        spells = elem.find_elements(xpath: spell_sel)
        spells.map! {|spell| spell.text.gsub("\n",' ').gsub('CAST','')}
        accum[spell_level] = spells
        accum
      end
    rescue
      all_spells = []
    end
  end

  def get_attack # TODO: needs formatting
    attacks = @page.find_elements(xpath: @csv[:attacks])
    attacks.map! {|attack| attack.text.gsub("\n",' ')} ; attacks
  end

  def get_skills(skill_data={})
    skill_proficiency = @page.find_elements(xpath: @csv[:skill_proficiency])
    skill_proficiency.map! {|pr| pr.attribute('data-original-title') }

    skills = @page.find_elements(xpath: @csv[:skills])
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

def parse_csv(file)
  file = CSV.read(file)
  file.inject({}) {|hh, (k, sel)| hh[k.to_sym] = sel ; hh }
end

def process
  character = Character.new(:yoshimo)
  character.display
end

process
# puts parse_csv
