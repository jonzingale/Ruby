DndStub = 'https://www.dndbeyond.com/profile/Mortekai/characters/'

class Agent
  attr_accessor :driver, :options, :page, :wait

  def initialize(character_id)
    @options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    @driver  = Selenium::WebDriver.for(:chrome, options: options)
    @wait = Selenium::WebDriver::Wait.new(:timeout => 15)
    @driver.manage.window.resize_to(1440, 1080)
    @page = get_character_page(character_id)
  end

  def quit
    driver.quit
  end

  def get_character_page(character_id)
    driver.get(DndStub+character_id)
    sleep(1)
    driver
  end
end
