require 'Mechanize'
require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'
require 'pry'
# require 'mysql2'
# http://www.photoenforced.com/#{state}.html
  DESKTOP_PATH = File.expand_path('../../..', __FILE__).freeze

  RELICAM_ROWS = './/table[@class="table3"]/tr'.freeze
  CSV_HEADERS = %w(state city cross_street fine camera_type notes map).freeze
  HEADER_SYMBOLS = CSV_HEADERS.map(&:to_sym).freeze
  BASE_URL = 'http://www.ecriteria.net/'.freeze
  FIRST_STUB = 'eCriteriaSearchCriteriaAction.asp'.freeze
  ACTION_SEL = './/a[contains(@href,"form1.submit")]'.freeze
  ACTION_REGEX = /asp\?(.+)'\;window/.freeze

####GET EVERYTHING
  BIG_QUERY1 = { 'DBName' => 'photo', 'T_e_type' => '',
             'T_e_metro' => '', 'T_e_city' => '',
             'T_e_street1' => '', 'btnAction' => 'Search Database',
             'DBName0' => 'photo'}.freeze

  BIG_QUERY2 = { 'DBName' => 'photo', 
             'DatabaseID' => '10186', 
             'T_e_metro' => '',
             'T_e_type' => ''}.freeze
######
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
    initialize_csv ; agent = Mechanize.new
    page = agent.post(BASE_URL+FIRST_STUB,BIG_QUERY1)
    # page = agent.post(BASE_URL+FIRST_STUB,QUERY1)
    html_to_csv(page) ; get_next_action(page)

    while !@next_action.nil?
      page = agent.post(BASE_URL+@next_action,BIG_QUERY2)
      # page = agent.post(BASE_URL+@next_action,QUERY2)
      html_to_csv(page) ; get_next_action(page)
      break if ACTION_REGEX.match(@next_action.to_s).nil?
    end
  end

process
