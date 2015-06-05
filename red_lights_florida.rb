require 'Mechanize'
require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'
require 'pry'
# require 'mysql2'
## FRIDAY
## 1) land a general DB_page, not just red lights, not Florida

    RELICAM_ROWS = './/table[@class="table3"]/tr'.freeze
    CSV_HEADERS = %w(state city cross_street fine camera_type notes map).freeze
    HEADER_SYMBOLS = CSV_HEADERS.map(&:to_sym).freeze
    DESKTOP_PATH = File.expand_path('../../..', __FILE__).freeze
    BASE_URL = 'http://www.ecriteria.net/'.freeze
    FIRST_STUB = 'eCriteriaSearchCriteriaAction.asp'.freeze
    ACTION_SEL = './/a[contains(@href,"form1.submit")]'.freeze
    ACTION_REGEX = /asp\?(.+)'\;window/.freeze

    QUERY1 = { 'DBName' => 'photo', 'T_e_type' => 'Red',
               'T_e_metro' => 'Florida', 'T_e_city' => '',
               'T_e_street1' => '', 'btnAction' => 'Search Database',
               'DBName0' => 'photo'}.freeze
  
    QUERY2 = { 'DBName' => 'photo', 
               'DatabaseID' => '10186', 
               'T_e_metro' => 'Florida',
               'T_e_type' => 'Red'}.freeze

  def initialize_csv
    CSV.open("#{DESKTOP_PATH}/redlight_cameras.csv", 'w') do |csv|
      csv << CSV_HEADERS.map(&:upcase)
    end
  end

  def html_to_csv(page)
    # State, City / Suburb, Cross Street, Fine, Camera Type, Notes and Map
    CSV.open("#{DESKTOP_PATH}/redlight_cameras.csv", 'a') do |csv|    
      page.search(RELICAM_ROWS).each do |tr| ; row = {}
        tr.search('.//td').each_with_index do |td, i|
          row[HEADER_SYMBOLS[i]] = td.text
        end unless /State/i.match(tr.text)
        csv << row.values unless row.empty?
      end
    end
  end

  def get_next_action(page)
    next_action = page.search(ACTION_SEL).detect{|a|/next/i.match(a.inner_text)}
    @next_action = /'(.+)'/.match(next_action['href'])[1]
  end


  def process

    initialize_csv
    agent = Mechanize.new

    page = agent.post(BASE_URL+FIRST_STUB,QUERY1)
    html_to_csv(page) ; get_next_action(page)


$i = 0

    while (!@next_action.nil? && $i<3)

      page = agent.post(BASE_URL+@next_action,QUERY2)
      html_to_csv(page) ; get_next_action(page)

      break if ACTION_REGEX.match(@next_action.to_s).nil?

$i += 1
    end
  end

process


byebug ; 4





 # second condition for testing
      # url = "#{DESKTOP_PATH}/byebug_relicam_#{$i == 0 ? 'page2' : 'last'}.html"
      # page = Nokogiri::HTML(open(url))
    # BASE_URL = 'http://www.photoenforced.com/database.html#.VVPKV9pVhBe'.freeze
    # page = agent.post(PAGE_PATH+'count=2436&LR=26&UR=50',QUERY2)
    # page = Nokogiri::HTML(open("#{DESKTOP_PATH}/byebug_relicam.html"))
    # page = Nokogiri::HTML(open("#{DESKTOP_PATH}/byebug_relicam.html"))
    # page_2 = Nokogiri::HTML(open("#{DESKTOP_PATH}/byebug_relicam_page2.html"))
    # page_last = Nokogiri::HTML(open("#{DESKTOP_PATH}/byebug_relicam_last.html"))




