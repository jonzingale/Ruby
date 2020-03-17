#!/usr/bin/env ruby
require 'mechanize'
require 'byebug'
require 'date'
require 'csv'

DATE = Date.today.strftime('%Y-%m-%d')
TIME = DateTime.now.strftime('%I:%M %p')

COVID_URL = 'https://e.infogram.com/6280a269-a8ec-4d0b-8810-363d5057e67e?parent_url=http%3A%2F%2Fnmindepth.com%2F2020%2F03%2F13%2Fmap-new-mexico-covid-19-cases%2F'
DATA_CSV = "data.csv".freeze

CASE_REGEX = /currently (\d+|no) cases/i
DEATH_REGEX = /(\d+|no) ?reported? deaths/i
RECOVERY_REGEX = /(\d+|no) ?reported? recoveries/i
COUNTIES_REGEX = /"data":\[\[(.+)\]\]/

class Agent
  attr_accessor :body, :counties, :total_cases, :deaths, :recoveries

  def initialize
    @body = get_body
    @counties = get_effected_counties
    @total_cases = get_case_by_type(CASE_REGEX)
    @deaths = get_case_by_type(DEATH_REGEX)
    @recoveries = get_case_by_type(RECOVERY_REGEX)
  end

  def get_body
    agent = Mechanize.new
    agent.redirect_ok = true
    landing_page = agent.get(COVID_URL)
    landing_page.body
  end

  def get_case_by_type(regex)
    val = regex.match(@body)[1]
    val == 'no' ? 0 : val.to_i
  end

  def present?(val)
    !(val.nil? || val.empty?)
  end

  def get_effected_counties
    json_match = /"data":\[\[(.+)\]\]/.match @body
    json = JSON.parse("{#{json_match}}")['data'][0]
    json.each_with_object({}) do |rec, hh|
      rec[1] = 0 unless present?(rec[1])
      hh.merge!(rec[0] => rec[1].to_i)
    end
  end
end

def return_covid19_results
  CSV.read(DATA_CSV)
end

def process
  agent = Agent.new

  CSV.open(DATA_CSV, 'a') do |csv|
    data = [DATE, TIME, agent.total_cases, agent.deaths, agent.recoveries]
    data << agent.counties.to_s
    csv << data
  end
end

process
# return_covid19_results