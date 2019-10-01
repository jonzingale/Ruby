require 'selenium-webdriver'
require 'byebug'

LOGIN_URL = 'https://www.dndbeyond.com/sign-in?returnUrl='

class Agent
  attr_accessor :driver, :options

  def initialize
    @options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    @driver = Selenium::WebDriver.for(:chrome, options: options)
  end
end

agent = Agent.new
driver = agent.driver

driver.get(LOGIN_URL)

driver.find_elements(:xpath, '//html//a').map(&:text)

byebug
driver.quit
