# !/usr/bin/env ruby
require 'active_support'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'date'
require 'csv'

BASE_URL = "http://picbreeder.org"
FILES_PATH = File.expand_path('./../', __FILE__).freeze
BREEDER_INITS = "#{FILES_PATH}/data.csv".freeze

SEARCH_URL = "http://picbreeder.org/search/search.php"

class USER
  attr_accessor :username, :password

  def initialize
    header, (@username, @password), *_ = CSV.read(BREEDER_INITS)
  end
end

def registeredUser(user)
  agent = Mechanize.new
  landing_page = agent.get(BASE_URL)

  form = landing_page.forms.first
  form['myusername'] = user.username
  form['mypassword'] = user.password
  page = form.submit

  # form['logout'] = 'true' # Not yet coded
  # page = form.submit
end

def searchImages
  agent = Mechanize.new
  landing_page = agent.get(SEARCH_URL)

byebug

end

# user = USER.new
# process user

searchImages