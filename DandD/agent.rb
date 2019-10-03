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
