# !/usr/bin/env ruby
require 'mechanize'
require 'byebug'

BILL_STUB = 'https://nmlegis.gov/Legislation/'
BASE_URL = 'https://nmlegis.gov/Legislation/Legislation_List'
LEGIS_TABLE = 'table[@id="MainContent_gridViewLegislation"]'
PDF_REGEX = /\Sessions.*bills.*.pdf/

def formFiller form
  form['ctl00$MainContent$ddlSessionStart'] = '56' # any value 1-56
  form['ctl00$MainContent$ddlSessionEnd'] = '56' # any value 1-56
  form['ctl00$MainContent$chkSearchBills'] = 'on'
  form['ctl00$MainContent$chkSearchMemorials'] = 'on'
  form['ctl00$MainContent$chkSearchResolutions'] = 'on'
  form['ctl00$MainContent$btnSearch'] = 'Go'
  form['ctl00$MainContent$ddlResultsPerPage'] = '2000'
end

agent = Mechanize.new
page = agent.get(BASE_URL)

form = page.forms.first
formFiller form
# puts forms.values # to see what is submitted
page = form.click_button  
table = page.at(LEGIS_TABLE)
links = table.search('td//a/@href')

# remove .take(2) when attempting larger queries
good_links = links.reject {|l| /Members/.match(l) }.take(2)

# bill pdf requests
bills = good_links.inject([]) do |acc, link|
  billPage = agent.get(BILL_STUB + link)
  acc << billPage.search('a/@href').select{|href| PDF_REGEX.match(href)}
end

puts bills
