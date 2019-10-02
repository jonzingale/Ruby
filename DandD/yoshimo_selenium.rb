require 'selenium-webdriver'
require 'byebug'
require 'json'

Yoshimo_Login = 'https://www.dndbeyond.com/profile/Mortekai/characters/3641195'

AbilityFields = %w(strength dexterity constitution intelligence wisdom charisma)
AbilitySel = "div[%i]//div[@class='ct-ability-summary__primary']"
AllAbilitySel = '//div[@class="ct-quick-info__abilities"]'

NameSel = "ct-character-tidbits__name"
LevelSel = "ct-character-tidbits__xp-level"
ACSel = "ct-armor-class-box__value"
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
    sleep(2)
    driver
  end
end

class Character
  attr_accessor :name, :level, :armor_class, :abilities

  # Perhaps use a Struct.new so that all stats are hashes
  # and a Json can be built up.

  def initialize(page)
    @page = page
    @name = page.find_element(class: NameSel).text
    @level = page.find_element(class: LevelSel).text
    @armor_class = page.find_element(class: ACSel).text
    @abilities = get_abilities
  end

  def get_abilities(abHash={})
    elem = @page.find_element(xpath: AllAbilitySel)

    AbilityFields.each_with_index do |a, i|
       abScore = elem.find_element(xpath: AbilitySel % (i+1)).text
       abHash[a] = abScore.gsub("\n", '')
    end

    abHash
  end
end


def process
  agent = Agent.new
  yoshimo = Character.new(agent.page)
  puts [:name, :level, :armor_class, :abilities].map {|sym| yoshimo.send(sym).to_s}
  agent.quit
end

process
