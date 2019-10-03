require 'selenium-webdriver'
require 'byebug'
require 'json'
require 'csv'

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

SelStub = "//div[@class='%s']"

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

    elems.each_with_index do |ps, i|
      data[fields[i]] = ps.text.gsub("\n",'')
    end ; data
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
