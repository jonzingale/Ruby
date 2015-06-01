#!/usr/bin/env ruby
require 'byebug'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'date'

# the idea here is to check a library account for outstanding books
# and to renew if close. Email if failure. ran as cron task.

BASE_URL = 'http://stjohnsnm.ipac.dynixasp.com/ipac20/ipac.jsp?profile=meem'.freeze
SESSION_URL =(BASE_URL+"&session=%s&menu=account").freeze

###land meem library
landing_page = Nokogiri::HTML(open(BASE_URL))
session = URI.encode(landing_page.at('.//input[@name="session"]')['value'])
# form_page = Nokogiri::HTML(open(session_url = SESSION_URL % session))

agent = Mechanize.new
form_page = agent.get(session_url = SESSION_URL % session)
form = form_page.forms.first

puts "enter a borrower id"
borrower_id = gets.chomp
form['sec1'] = borrower_id

# do i need to submit all fields? nope.
# form.keys.zip(form.values)
byebug
page = form.submit



byebug




# byebug ; '5'


