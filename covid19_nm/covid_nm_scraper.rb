# !/usr/bin/env ruby
require 'mechanize'
require 'byebug'
require 'date'
require 'csv'

COVID_URL = 'https://e.infogram.com/6280a269-a8ec-4d0b-8810-363d5057e67e?parent_url=http%3A%2F%2Fnmindepth.com%2F2020%2F03%2F13%2Fmap-new-mexico-covid-19-cases%2F'
NOW = Date.today.strftime('%Y-%m-%d')
DATA_CSV = "data.csv".freeze

def process
  last_date = get_last_date
  to_csv(NOW, get_num_cases) if  last_date < NOW
end

def get_num_cases
  agent = Mechanize.new
  agent.redirect_ok = true
  landing_page = agent.get(COVID_URL)
  body = landing_page.body
  num_cases = /there are currently (\d+)/i.match(body)[1]
  num_cases.to_i
end

def get_last_date
  csv = CSV.read(DATA_CSV, headers: true, return_headers: false)
  Date.parse(csv[-1][0]).strftime('%Y-%m-%d')
end

def to_csv(date, num_of_cases)
  CSV.open(DATA_CSV, 'a') { |csv| csv << [date, num_of_cases] }
end

process