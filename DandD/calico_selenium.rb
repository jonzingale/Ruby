require 'selenium-webdriver'
require 'byebug'
require 'json'

LOGIN_URL = 'https://www.dndbeyond.com/sign-in?returnUrl='

class Agent
  attr_accessor :driver, :options, :username, :password

  def initialize
    @options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    @driver  = Selenium::WebDriver.for(:chrome, options: options)
    @username, @password = get_credentials
  end

  def get_credentials
    file = File.read('credentials.json')
    data_hash = JSON.parse(file)
    data_hash.to_a.first
  end
end

agent = Agent.new
driver = agent.driver

driver.get(LOGIN_URL)

# driver.find_elements(:xpath, '//html//a').map(&:text)
# tw_button = driver.find_elements(:link_text, 'Twitch')[0]
tw_button = driver.find_elements(:xpath, '//button')[1] # todo get button name
tw_button.click

# get_username
username = driver.find_element(:xpath, '//form//div/input["username"]')
username.send_keys(agent.username)

# get_password
password = driver.find_element(:xpath, '//form//div/input["password"]')
password.send_keys(agent.password)

# driver.current_url
driver.find_element(:xpath, '//button').click

byebug
driver.quit
