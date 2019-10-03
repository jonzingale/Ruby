require 'selenium-webdriver'
require 'byebug'
require 'json'

Yoshimo_Login = 'https://www.dndbeyond.com/profile/Mortekai/characters/3641195'

AbilityFields = %w(strength dexterity constitution intelligence wisdom charisma)
AbilitySel = "//div[@class='ct-ability-summary__primary']"

PassivityFields = %w(perception investigation insight)
PassiveSel = "//div[@class='ct-senses__callout-value']"

SavingThrowsFields = %w(strength dexterity constitution intelligence wisdom charisma)
SavingThrowsSel = "//div[@class='ct-saving-throws-summary__ability-modifier']"

ProficiencySel = "ct-proficiency-bonus-box__value"
NameSel = "ct-character-tidbits__name"
LevelSel = "ct-character-tidbits__xp-level"
ACSel = "ct-armor-class-box__value"
WalkingSel = 'ct-speed-box__box-value'
MaxXP = "ct-health-summary__hp-number"

# TODO:
# BUILD AS AN API, THINK ABOUT STRUCTURING AS JSON
# Perhaps use a Struct.new so that all stats are hashes
# and a Json can be built up.
# Customer = Struct.new(:name, :address) do

class Agent
  attr_accessor :driver, :options, :page, :wait

  def initialize
    @options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    @driver  = Selenium::WebDriver.for(:chrome, options: options)
    @wait = Selenium::WebDriver::Wait.new(:timeout => 15)
    @driver.manage.window.resize_to(1440, 1080)
    @page = get_page
  end

  def quit
    driver.quit
  end

  def get_page
    driver.get(Yoshimo_Login)
    sleep(1)
    driver
  end
end

class Character
  attr_accessor :name, :level, :armor_class, :abilities, :proficiency,
    :walking_speed, :maxXP, :passives, :saving_throws

  def initialize(page)
    @page = page
    @abilities = {}
    @passives = {}
    @saving_throws = {}

    @name = get_text(NameSel)
    @level = get_text(LevelSel)
    @armor_class = get_text(ACSel)
    @proficiency = get_text(ProficiencySel)
    @walking_speed = get_text(WalkingSel)
    @maxXP = get_text(MaxXP)

    get_abilities
    get_passives
    get_saving_throws
    # byebug
  end

  def get_text(selector, type='c')
    case type
    when 'c'
      @page.find_element(class: selector).text.gsub("\n", '')
    when 'x'
      @page.find_element(xpath: selector).text.gsub("\n", '')
    else
      'Error Bad Selector Type for get_text'
    end
  end

  def get_saving_throws # perhaps generalize and include passives and abilities
    saving_throws = @page.find_elements(xpath: SavingThrowsSel)

    saving_throws.each_with_index do |st, i|
      @saving_throws[SavingThrowsFields[i]] = st.text.gsub("\n",'')
    end
  end

  def get_passives
    passives = @page.find_elements(xpath: PassiveSel)

    passives.each_with_index do |ps, i|
      @passives[PassivityFields[i]] = ps.text.gsub("\n",'')
    end
  end

  def get_abilities
    abilities = @page.find_elements(xpath: AbilitySel)

    abilities.each_with_index do |ab, i|
      @abilities[AbilityFields[i]] = ab.text.gsub("\n",'')
    end
  end

end

def process
  agent = Agent.new
  yoshimo = Character.new(agent.page)

  values = [:name, :level, :armor_class, :proficiency,
    :walking_speed, :maxXP, :passives, :saving_throws, :abilities]

  puts values.map {|sym| yoshimo.send(sym).to_s}
  agent.quit
end

process
