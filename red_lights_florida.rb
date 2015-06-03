require 'Mechanize'
require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'
require 'pry'
# require 'mysql2'
    # page = agent.post(PAGE_PATH+'count=2436&LR=26&UR=50',QUERY2)
    BASE_URL = 'http://www.photoenforced.com/database.html#.VVPKV9pVhBe'.freeze

    RELICAM_ROWS = './/table[@class="table3"]/tr'.freeze
    CSV_HEADERS = %w(state city cross_street fine camera_type notes map).freeze
    HEADER_SYMBOLS = CSV_HEADERS.map(&:to_sym).freeze
    DESKTOP_PATH = File.expand_path('../../..', __FILE__).freeze
    PAGE_PATH = 'http://www.ecriteria.net/eCriteriaSearchCriteriaActionResult.asp?'.freeze
    FIRST_URL = 'http://www.ecriteria.net/eCriteriaSearchCriteriaAction.asp'.freeze
    ACTION_SEL = './/a[contains(@href,"form1.submit")]'.freeze
    ACTION_REGEX = /asp\?(.+)'\;window/.freeze

    QUERY1 = { 'DBName' => 'photo', 'T_e_type' => 'Red',
               'T_e_metro' => 'Florida', 'T_e_city' => '',
               'T_e_street1' => '', 'btnAction' => 'Search Database',
               'DBName0' => 'photo'}.freeze
  
    # QUERY2 MAY REQUIRE QUERY1
    QUERY2 = { 'DBName' => 'photo', 
               'DatabaseID' => '10186', 
               'T_e_metro' => 'Florida',
               'T_e_type' => 'Red'}.freeze

    # # page :base_page, 'http://www.photoenforced.com/database.html#.VVPKV9pVhBe'
    # define_form :red_light, nil, create_form: true, action: BASE_URL do
    #   field('DBName','photo')
    #   field('T_e_type','Red')
    #   field('T_e_metro','Florida')
    #   field('T_e_city','')
    #   field('T_e_street1','')
    #   field('btnAction','Search Database')
    #   field('DBName0','photo')
    # end

    # attr_reader :action
    # define_form :next, nil, create_form: true, action: '#{recipe.action}' do
    #   #leaving out the sql_query seems bring back not just redlight info
    #   # field('SQL',"SELECT e_ID00000, e_metro, e_city, e_street1, e_fine, e_type, e_notes, e_map FROM e_photo WHERE e_metro LIKE '%Florida%' AND e_type LIKE '%Red%'")
    #   field('DatabaseID','10186')
    #   field('DBName','photo')
    # end

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
        csv << row.values
      end
    end
  end

  def process
    initialize_csv

    agent = Mechanize.new

    # page = agent.post(FIRST_URL,QUERY1) # wait to go live
    page = Nokogiri::HTML(open("#{DESKTOP_PATH}/byebug_relicam.html"))
    @next_action = page.search(ACTION_SEL).detect{|a|/next/i.match(a.inner_text)}
    html_to_csv(page)

####WORKOUT THIS PART
    # page = Nokogiri::HTML(open("#{DESKTOP_PATH}/byebug_relicam.html"))
    # page_2 = Nokogiri::HTML(open("#{DESKTOP_PATH}/byebug_relicam_page2.html"))
    # page_last = Nokogiri::HTML(open("#{DESKTOP_PATH}/byebug_relicam_last.html"))
$i = 0

    while (!@next_action.nil? && $i<5) # second condition for testing
      url = "#{DESKTOP_PATH}/byebug_relicam_#{$i == 0 ? 'page2' : 'last'}.html"
      page = Nokogiri::HTML(open(url))
      @next_action = page.search(ACTION_SEL).detect{|a|/next/i.match(a.inner_text)}
      html_to_csv(page)

      break if ACTION_REGEX.match(@next_action.to_s).nil?
      next_url = PAGE_PATH+(ACTION_REGEX.match(@next_action.to_s)[1])
      # agent.post(next_url,QUERY2)

$i += 1
    end
  end

process


byebug ; 4














