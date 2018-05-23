# set ruby ruby-2.3.1

require 'rubygems'
require 'byebug'

require "selenium-webdriver"
require "rest-client"


SCRATCH_URL = "http://picbreeder.org/user/editgenome.php?sid=-1&pid=-1"
SOAP_URL = "http://www.picbreeder.org:8080/axis/services/WebNeatClient?wsdl"

class Agent
  attr_accessor :driver

  def initialize
    # @mouse = Selenium::WebDriver.mouse
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

  def url
    @driver.current_url
  end
end

# <applet code="client.gui.Applet" archive="client.jar" width="709" height="673" align="middle">
#   <param name="seriesId" value="-1">
#   <param name="parentId" value="-1">
#   <param name="username" value="anonymous">
#   <param name="password" value="anonymous">
#   <param name="webservices" value="http://www.picbreeder.org:8080/axis/services/WebNeatClient?wsdl">
# </applet>

agent = Agent.new

elem1 = agent.driver.find_element(:xpath, "//applet")
puts agent.driver.find_element(:xpath => "//body").text

byebug
Selenium::WebDriver::Mouse.send(:move_by,10,10)

