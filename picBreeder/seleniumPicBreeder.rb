# set ruby ruby-2.3.1

require 'rubygems'
require 'byebug'

require "selenium-webdriver"
require "rest-client"


SCRATCH_URL = "http://picbreeder.org/user/editgenome.php?sid=-1&pid=-1"

class Agent
  attr_accessor :driver

  def initialize
    @driver = Selenium::WebDriver.for :safari
    driver.manage.window.maximize
    get(SCRATCH_URL)
  end

  def get(url)
    @driver.get url
  end

  def quit
    @driver.quit
  end
end


agent = Agent.new

element = agent.driver.find_element(:name, "username")
byebug

4