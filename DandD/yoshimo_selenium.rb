require 'selenium-webdriver'
require 'byebug'
require 'json'

Yoshimo_Login = 'https://www.dndbeyond.com/profile/Mortekai/characters/3641195'

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
  attr_accessor :name, :level, :abilities, :armor_class

  def initialize(page, wait)
    @page = page
    @abilities = get_abilities

    byebug

    @name = page.find_element(:class,"ct-character-tidbits__name").text
    @level = page.find_element(:class,"ct-character-tidbits__xp-level").text
    @armor_class = page.find_element(:class, "ct-armor-class-box__value").text

  end

  def sheet_node
    @page.find_element(:xpath, "//div[@class='ct-character-sheet__inner']/div")
  end

  def get_abilities
    abilities = @page.find_element(xpath: '//div[@class="ct-quick-info__abilities"]')

    abils = %w(strength dexterity constitution intelligence wisdom charisma)
    ab_hash = {}

    abils.each_with_index do |a, i|
      ab_hash[a] = abilities.find_element(xpath: "div[#{i+1}]//div[@class='ct-ability-summary__primary']").text
    end

    ab_hash
  end
end


def process
  agent = Agent.new
  yoshimo = Character.new(agent.page, agent.wait)
  puts [:name, :level, :armor_class].map {|sym| yoshimo.send(sym).to_s}
  agent.quit
end

process
