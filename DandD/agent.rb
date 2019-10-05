class Agent
  attr_accessor :driver, :options, :page, :wait

  def initialize(path)
    @options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    @driver  = Selenium::WebDriver.for(:chrome, options: options)
    @wait = Selenium::WebDriver::Wait.new(:timeout => 2)
    @driver.manage.window.resize_to(1440, 1080)
    @page = get_path(path)
  end

  def quit
    driver.quit
  end

  def get_path(path)
    driver.get(path)
    sleep(2)
    driver
  end
end
