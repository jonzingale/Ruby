require 'Mechanize'
require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'
require 'pry'
# http://www.photoenforced.com/#{state}.html
  DESKTOP_PATH = File.expand_path('../../..', __FILE__).freeze
  FIRST_ACTION = 'eCriteriaSearchCriteriaActionResult.asp?count=2436&LR=1&UR=25s'.freeze
  CSV_HEADERS = %w(state city cross_street fine camera_type notes map).freeze
  ACTION_SEL = './/a[contains(@href,"form1.submit")]'.freeze
  RELICAM_ROWS = './/table[@class="table3"]/tr'.freeze
  HEADER_SYMBOLS = CSV_HEADERS.map(&:to_sym).freeze
  BASE_URL = 'http://www.ecriteria.net/'.freeze
  ACTION_REGEX = /asp\?(.+)'\;window/.freeze
  @next_action = FIRST_ACTION

  ALLDATA_QUERY = { 'DBName' => 'photo', 'DatabaseID' => '10186', 
                    'T_e_metro' => '', 'T_e_type' => ''}.freeze
                  # 'T_e_metro' => 'FLORIDA', 'T_e_type' => 'RED'

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
    while !@next_action.nil?
      page = agent.post(BASE_URL+@next_action, ALLDATA_QUERY)
      html_to_csv(page) ; get_next_action(page)
      break if ACTION_REGEX.match(@next_action.to_s).nil?
    end
  end

process
