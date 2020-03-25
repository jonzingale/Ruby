#!/usr/bin/env ruby
require 'mechanize'
require 'byebug'
require 'date'
require 'csv'

DATE = Date.today.strftime('%Y-%m-%d')
TIME = DateTime.now.strftime('%I:%M %p')

COVID_URL = 'https://e.infogram.com/6280a269-a8ec-4d0b-8810-363d5057e67e?parent_url=http%3A%2F%2Fnmindepth.com%2F2020%2F03%2F13%2Fmap-new-mexico-covid-19-cases%2F'
AGES_URL = 'https://docs.google.com/spreadsheets/u/0/d/e/2PACX-1vRfslCmEsupDwXa2wGsd6AnR1i6gLEPd_nm_RUUw-M5N4rH3AbFDDQw1N5HGCKCLA/pubhtml/sheet?headers=false&gid=567443277'
AGE_SEL = %W[0s 10s 20s 30s 40s 50s 60s 70s 80s 90s 100s N/A]

DATA_CSV = 'data/data.csv'.freeze
COUNTY_CSV = 'data/county.csv'.freeze
AGE_CSV = 'data/age.csv'.freeze

CASE_REGEX = /been (\d+|no) cases/i
DEATH_REGEX = /(\d+|no) ?reported? deaths?/i
RECOVERY_REGEX = /(\d+|no) ?reported? recover/i
COUNTY_DATA_REGEX = /\[\"(\w+\W?\W?\w+ ?\w*)\",\"(\d+)\"/
COUNTIES_REGEX = /"data":\[\[(.+),\[null/
TABLE_REGEX = /<tbody.+tbody>/
AGE_REGEX = /(\d+s|N\/A)/

class Agent
  attr_accessor :body, :counties, :total_cases, :deaths,
    :recoveries, :age_body, :ages

  def initialize(use_fixture=false)
    @body = get_body(use_fixture)
    @age_body = get_age_body(use_fixture)
    @counties = get_effected_counties
    @total_cases = get_case_by_type(CASE_REGEX)
    @deaths = get_case_by_type(DEATH_REGEX)
    @recoveries = get_case_by_type(RECOVERY_REGEX)
    @ages = get_ages
  end

  def get_age_body(use_fixture)
    if use_fixture
      File.read('./data/age_body_fixture.html')
    else
      agent = Mechanize.new
      landing_page = agent.get(AGES_URL)
      landing_page.body
    end
  end

  def get_body(use_fixture)
    if use_fixture
      File.read('./data/body_fixture.html')
    else
      agent = Mechanize.new
      agent.redirect_ok = true
      landing_page = agent.get(COVID_URL)
      landing_page.body
    end
  end

  def get_case_by_type(regex)
    val = regex.match(@body)[1]
    val == 'no' ? 0 : val.to_i
  end

  def get_effected_counties
    json_match = COUNTIES_REGEX.match(@body)[1]
    clean_match = json_match.gsub('""','"0"')
    clean_match.scan(COUNTY_DATA_REGEX)
  end

  def get_ages
    age_array = [*0..11].map { 0 }
    table_match = TABLE_REGEX.match(@age_body)[0]
    table = Nokogiri.parse(table_match)
    rows = table.search('.//tr').drop(5)

    rows.each do |tr|
      val = tr.at('./td[2]').text
      age = AGE_REGEX.match(val)[1]
      ix = AGE_SEL.index(age)
      age_array[ix] += 1
    end
    age_array
  end

end

def return_covid19_results
  data_csv = CSV.read(DATA_CSV)
  county_csv = CSV.read(COUNTY_CSV)
  ages_csv = CSV.read(AGE_CSV)
  [data_csv, county_csv, ages_csv]
end

def save_data(agent)
  CSV.open(AGE_CSV, 'a') do |csv|
    csv << agent.ages
  end

  CSV.open(COUNTY_CSV, 'a') do |csv|
    csv << agent.counties.map(&:last)
  end

  CSV.open(DATA_CSV, 'a') do |csv|
    csv << [DATE, TIME, agent.total_cases, agent.deaths, agent.recoveries]
  end
end

def process(save_records = true, use_fixture = false)
  agent = Agent.new(use_fixture)
  save_records ? save_data(agent) : print(agent.ages)
end

save_records = true
use_fixture = false
process(save_records, use_fixture)
# return_covid19_results