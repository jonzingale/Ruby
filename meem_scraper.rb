# !/usr/bin/env ruby
require 'byebug'
require 'csv'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'net/smtp'
# TODO: 
# 	Hold Requests
# 	Caching dates
#   Emailing
#   Bibliography

# the idea here is to check a library account for outstanding books
# and to renew if close. Email if failure. ran as cron task.
NOW = Date.today.freeze
BORROWER_ID = 'AL911'.freeze
BASE_URL = 'http://stjohnsnm.ipac.dynixasp.com/ipac20/ipac.jsp?profile=meem'.freeze
SESSION_URL =(BASE_URL+"&session=%s&menu=account").freeze
SESSION_SEL = './/input[@name="session"]'.freeze
ACCOUNT_OPTIONS = %w(itemsout holds blocks info).freeze

EXPIRATION_COL_SEL = './/a[@class="normalBlackFont2"]/parent::td'.freeze
BOOK_SEL = './/table[@class="tableBackgroundHighlight"]//table[@class="tableBackground"]/parent::td/parent::tr'.freeze
BOOK_HEADERS = %w(book author library_of_congress checked_out due renewed).freeze
TITLE_SEL = './/a[@class="mediumBoldAnchor"]'.freeze

SUMMARY_SEL = './/table[@class="tableBackground"]//a[@class="normalBlackFont2"]'.freeze
# SUMMARY_HEADERS = ["Checked Out", "Overdue", "Lost", 
# 									 "Requested items ready for pick up", 
# 									 "Requested items not yet available", 
# 									 "Number of Blocks", "Current Balance"].freeze

DATA_HEADERS = %w(CARD_EXPIRATION NEXT_DUE).freeze
SUM_HEADERS = ["Checked Out", "Overdue", "Lost", 
							 "Ready for pick up", "Not yet available", 
							 "Number of Blocks", "Current Balance"].freeze

DATA_KEYS = [:expiration,:next_due]
SUM_KEYS = [:checked_out,:overdue,:lost,:pick_up,
						:not_available,:blocks,:balance].freeze	

DESKTOP_PATH = File.expand_path('./../src/meem_library', __FILE__).freeze
def str_to_date(date_str) ; Date.strptime(date_str, '%m/%d/%Y') ; end

## Email Builder
# def email_builder('message')
# message = <<MESSAGE_END
# From: meem_scraper_notification <less.secure.username@gmail.com>
# To: jon zingale <jonzingale@gmail.com>
# Subject: Library Update

# This is a test e-mail message.
# MESSAGE_END

# Net::SMTP.start('localhost') do |smtp|
#   smtp.send_message message, 'jonzingale@gmail.com>', # from
#                              'jonzingale@gmail.com>'	# to
# end
# end
##

## CSVs
def hash_to_csv(file_name, key_values, headers)
	file = "#{DESKTOP_PATH}/#{file_name}" # :: String x [Hash] x [String] -> [Hash]
  CSV.open(file, 'w'){|csv| csv << headers.map(&:upcase) } # comment out to queue
	CSV.open(file, 'a') { |csv| csv << key_values.map{|book| book.values.first} }
	read_csv(file_name,key_values.map(&:keys).flatten)
end

def read_csv(file_name, keys)# :: String x [Symbol] -> [Hash]
	csv = CSV.read("#{DESKTOP_PATH}/#{file_name}")
	csv.last.zip(keys).inject([]){|ary,kv| ary << {kv[1] => kv[0]} }
end # 1/1/1900, 6/9/2015

data_cache = read_csv('data_cache.csv', DATA_KEYS)
next_cache = hash_to_csv('data_cache.csv', data_cache, DATA_HEADERS)
puts "\n\nAre inverses? #{data_cache==next_cache}\n\n"
### ##


def process
###


# mail = Mail.new("To: jonzingale@gmail.com\r\nSubject: Hello\r\n\r\nHi there!")
# mail.body.to_s #=> 'Hi there!'
# mail.subject   #=> 'Hello'
# mail.to        #=> 'mikel@test.lindsaar.net'

byebug

##### HOW TO EXPIRE
# ## read csv
# ## (plenty of time)
# 	cond_1: if exp_date > NOW+30
# 		do nothing
# ## (about to expire)
# 	cond_2: if exp_date = or < NOW+30
# 		check date on account, replace date in data_cache if necessary
# 		email me "Renew your SJC library card by DATE"
# ## (expired:)
# 	cond_3: if exp_date = or < NOW, send string
# 		check date
# 		email me "Your SJC library card has expired."
# 		end program?

# data_cache[:expiration] = '1/1/1900'
# data_cache[:next_due] = '6/9/2015'

	# look up data

	data_cache = read_csv('data_cache.csv', DATA_KEYS)
# # card expiration and renewal conditions
	# case 2
	next_expires = str_to_date(data_cache[0][:expiration])
	if (expires_cond = next_expires <= NOW + 30)
		page =	Nokogiri::HTML(open("#{DESKTOP_PATH}/info.html"))

		# place who agent.get logic in here Wednesday.



		expires_td = page.search(EXPIRATION_COL_SEL).detect{|a|a.text =~/expires/i}
		next_expires = expires_td.at('.//following-sibling::td').text

		data_cache[0][:expiration] = next_expires
		data_cache = hash_to_csv('data_cache.csv', data_cache, DATA_HEADERS)
	end


byebug


	### renew conditions
	next_due = str_to_date(data_cache[0][:next_due])
	if (renew_cond = NOW > next_due - 5)
		# so we renewed, now save renewal_info to a file.
	
		## for scraping locally use Nokogiri.
		page =	Nokogiri::HTML(open("#{DESKTOP_PATH}/items_out.html"))
		
		book_data = page.search(BOOK_SEL).inject([]) do |data, book| ; row = {}
			row[:title] = /(.+)\//.match(book.at(TITLE_SEL).text)[1]
			row[:author] = /by (.+), \d+/.match(book.search('.//a')[1].text)[1]
			row[:id] = book.search('.//a')[2].text
			row[:check_out] = book.search('.//a')[3].text
			row[:due] = book.search('.//a')[4].text
			row[:renewed] = book.search('.//a')[5].text
			data << row
		end
	
		# stores book_data
		book_data = hash_to_csv('items_out.csv',book_data, BOOK_HEADERS)
	
		# stores new data_cache
		next_due = book_data.min_by{|data| str_to_date(data[:due])}[:due]
		data_cache[0][:next_due] = next_due
		data_cache = hash_to_csv('data_cache.csv', data_cache, headers)
	end
	###



byebug





byebug
	# land meem library
	agent = Mechanize.new
	landing_page = agent.get(BASE_URL)
	session = URI.encode(landing_page.at(SESSION_SEL)['value'])
	
	# enter borrower_id form
	form = agent.get(session_url = SESSION_URL % session).forms.first
	form['sec1'] = BORROWER_ID ; page = form.submit
	
	# scrapes links to the various account options
	# page =	Nokogiri::HTML(open("#{DESKTOP_PATH}/home_page.html"))
	hrefs = page.search('.//a/@href').map(&:value)
	links = ACCOUNT_OPTIONS.map{|opt| hrefs.detect{|href| /#{opt}$/.match(href)}}
	
	# scrapes account summary and returns csv
	data_as = page.search(SUMMARY_SEL).select{|data| /:/.match(data.inner_text)}
	summary_data = {} ; SUM_KEYS.zip(data_as).each do |sym, data|
		summary_data[sym] =  /: (.+)/.match(data.text)[1]
	end ; hash_to_csv('meem_summary.csv', [summary_data], SUM_HEADERS)

	# Expiration Date Block
	# page =	Nokogiri::HTML(open("#{DESKTOP_PATH}/info_out.html"))
	expires_str = 'still good' # use only when needed?
	if Date.strptime(expires_str, '%m/%d/%Y').nil?
		ts = /ts=(\d+)/.match(page.at('.//a[@title="Profile"]')['href'])[1]
		
		# ts is necessary for info page
		form = page.forms.first
		form['submenu'] = 'info'
		form['ts'] = ts
		info_page = form.submit
	
		expires_td = info_page.search('.//a[@class="normalBlackFont2"]/parent::td').detect{|a|a.text =~/expires/i}
		expires_str = expires_td.at('.//following-sibling::td').text # likely good enough
		expires_date = Date.strptime(expires_str, '%m/%d/%Y')
	end


	# ItemsOut block
	if (no_books_cond = summary_data[:checked_out] == '0')
		# perhaps email this message as well as the meem_summary.csv
		puts "\n\nYou currently have no books out\n\n"
	else
		form = page.forms.first
		form['submenu'] = 'itemsout'
		items_page = form.submit

		# page=	Nokogiri::HTML(open("#{DESKTOP_PATH}/items_out.html"))
		book_data = page.search(BOOK_SEL).inject([]) do |data, book| ; row = {}
			row[:title] = /(.+)\//.match(book.at(TITLE_SEL).text)[1]
			row[:author] = /by (.+), \d+/.match(book.search('.//a')[1].text)[1]
			row[:id] = book.search('.//a')[2].text
			row[:check_out] = book.search('.//a')[3].text
			row[:due] = book.search('.//a')[4].text
			row[:renewed] = book.search('.//a')[5].text
			data << row
		end ; hash_to_csv('items_out.csv',book_data, BOOK_HEADERS)


		# renew conditions
		# next_due = book_data.map{|data| Date.strptime(data[:due], '%m/%d/%Y')}.min
		# renew_cond = NOW > next_due - 5

		# repopulate dates database with new data
		# add to bibliography database
	end


	# grab next due date.
	# renew all near.
	# if any can't send email
	# log out
	
	byebug
	
	# log out
	logout_script = /(http.+)\',/.match(page.at(LOGOUT_REGEX)['href'])[1]
	agent.get(URI.decode(logout_url))
end

process
byebug ; '5'


# do i need to submit all fields? nope.
# form.keys.zip(form.values)



