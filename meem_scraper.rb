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

# the idea here is to check a library account for outstanding books
# and to renew if close. Email if failure. ran as cron task.

# SINCE THIS WILL BE ON GITHUB, BE CAREFUL WITH PASSWORDS AND SHIT!!!!
# FIGURE OUT HOW TO GET AROUND THE SUDO CALL.

NOW = Date.today.freeze
BASE_URL = 'http://stjohnsnm.ipac.dynixasp.com/ipac20/ipac.jsp?profile=meem'.freeze
SESSION_URL =(BASE_URL+"&session=%s&menu=account").freeze
SESSION_SEL = './/input[@name="session"]'.freeze
ACCOUNT_OPTIONS = %w(itemsout holds blocks info).freeze

EXPIRATION_COL_SEL = './/a[@class="normalBlackFont2"]/parent::td'.freeze
BOOK_SEL = './/table[@class="tableBackgroundHighlight"]//table[@class="tableBackground"]/parent::td/parent::tr'.freeze
BOOK_HEADERS = %w(renew_key book author library_of_congress checked_out due renewed).freeze
TITLE_SEL = './/a[@class="mediumBoldAnchor"]'.freeze

SUMMARY_SEL = './/table[@class="tableBackground"]//a[@class="normalBlackFont2"]'.freeze

DATA_HEADERS = %w(CARD_EXPIRATION NEXT_DUE).freeze
SUM_HEADERS = ["Checked Out", "Overdue", "Lost", 
							 "Ready for pick up", "Not yet available", 
							 "Number of Blocks", "Current Balance"].freeze

DATA_KEYS = [:expiration,:next_due]
SUM_KEYS = [:checked_out,:overdue,:lost,:pick_up,
						:not_available,:blocks,:balance].freeze	

# a source directory off of crude. --untracked.
FILES_PATH = File.expand_path('./../../src/meem_library', __FILE__).freeze

csv = CSV.read("#{FILES_PATH}/meem_inits.csv") ; keys = [:borrower_id, :email]
INITS_HASH = keys.zip(csv.last).inject({}){|h,kv| h.merge({kv[0] => kv[1]}) }.freeze

def str_to_date(date_str) ; Date.strptime(date_str, '%m/%d/%Y') ; end

## Email Builder
def email_builder(message)
	# %x(launchctl start org.postfix.master) # hmm, some other way?
	# %x(sudo launchctl start org.postfix.master) # hmm, some other way?
	file = File.open(FILES_PATH+'/library_notification_template.txt')
	message = '' ; file.each{|line| message << line}

	Net::SMTP.start('localhost') do |smtp| # from, to
	  smtp.send_message message, INITS_HASH[:email], INITS_HASH[:email]
	end
end
##

## CSVs
def hash_to_csv(file_name, key_values, headers)
	file = "#{FILES_PATH}/#{file_name}" # :: String x [Hash] x [String] -> [Hash]
  CSV.open(file, 'w'){|csv| csv << headers.map(&:upcase) }
	CSV.open(file, 'a'){|csv| key_values.map(&:values).each{|line| csv << line }}
	# read_csv(file_name,key_values.map(&:keys).flatten)
end

def read_csv(file_name, keys)# :: String x [Symbol] -> [Hash]
	csv = CSV.read("#{FILES_PATH}/#{file_name}")
	keys.zip(csv.last).inject({}){|h,kv| h.merge({kv[0] => kv[1]}) }
end # 1/1/1900, 6/9/2015
##


def process
	# land meem library
	agent = Mechanize.new
	landing_page = agent.get(BASE_URL)
	session = URI.encode(landing_page.at(SESSION_SEL)['value'])
	
	## comment out when testing.
	# enter borrower_id form
	form = agent.get(session_url = SESSION_URL % session).forms.first
	form['sec1'] = INITS_HASH[:borrower_id] ; page = form.submit
####################

  ## EXPIRATION conditions : case 2 ### want them in same hash!!!!
	data_cache = read_csv('data_cache.csv', DATA_KEYS)
	next_expires = str_to_date(data_cache[:expiration])
	if (expires_cond = next_expires <= NOW + 30)
		# TODO: set some kind of email flag to true.
		# create an appropriate response message

		# info_page =	Nokogiri::HTML(open("#{FILES_PATH}/info.html"))
		ts = /ts=(\d+)/.match(page.at('.//a[@title="Profile"]')['href'])[1]
		form = page.forms.first ; form['submenu'] = 'info' ; form['ts'] = ts
		info_page = form.submit

		expires_td = info_page.search(EXPIRATION_COL_SEL).detect{|a|a.text =~/expires/i}
		next_expires = expires_td.at('.//following-sibling::td').text

		data_cache[:expiration] = next_expires
		data_cache = hash_to_csv('data_cache.csv', [data_cache], DATA_HEADERS)
	end
  #

	## renew conditions
	next_due = str_to_date(data_cache[:next_due])
	if (renew_cond = NOW > next_due - 5)
		# TODO: set some kind of email flag to true.
		# create an appropriate response message

		# items_page =	Nokogiri::HTML(open("#{FILES_PATH}/items_out.html"))
		ts = /ts=(\d+)/.match(page.at('.//a[@title="Checked Out"]')['href'])[1]
		form = page.forms.first ; form['submenu'] = 'itemsout' ; form['ts'] = ts
		items_page = form.submit

		book_data = items_page.search(BOOK_SEL).inject([]) do |data, book|; row = {}
			row[:renew_key] =  book.at('.//input[@name="renewitemkeys"]')['value']
			row[:title] = /(.+)\//.match(book.at(TITLE_SEL).text)[1]
			row[:author] = /by (.+), \d+/.match(book.search('.//a')[1].text)[1]
			row[:id] = book.search('.//a')[2].text
			row[:check_out] = book.search('.//a')[3].text
			row[:due] = book.search('.//a')[4].text
			row[:renewed] = book.search('.//a')[5].text
			data << row
		end

		# get renew_keys for books due within the 5 days.
		books_due = book_data.select{|book| str_to_date(book[:due]) - NOW < 5 }
		renew_keys = books_due.each{|book|form['renewitemkeys'] = book[:renew_key]}
		form['renewitems'] = 'Renew'
		items_page = form.submit

		# stores new items_out
		hash_to_csv('items_out.csv',book_data, BOOK_HEADERS)

		# stores new data_cache
		next_due = book_data.min_by{|data| str_to_date(data[:due])}[:due]
		data_cache[:next_due] = next_due
		data_cache = hash_to_csv('data_cache.csv',[data_cache], DATA_KEYS)

		# RENEWAL POST
		# Can renew multiple entries at once. should I??
		# http://stjohnsnm.ipac.dynixasp.com/ipac20/ipac.jsp
			# session:14HE058C69468.1082
			# profile:meem
			# renewitemkeys:20013504
			# renewitemkeys:25089696
			# renewitems:Renew
			# menu:account
			# submenu:itemsout
		# end
	end

email_builder('someshit')
byebug
	# SUMMARY BLOCK
	# # scrapes account summary and returns csv
	# data_as = page.search(SUMMARY_SEL).select{|data| /:/.match(data.inner_text)}
	# summary_data = {} ; SUM_KEYS.zip(data_as).each do |sym, data|
	# 	summary_data[sym] =  /: (.+)/.match(data.text)[1]
	# end ; hash_to_csv('meem_summary.csv', [summary_data], SUM_HEADERS)

	# LOG OUT BLOCK
	# logout_script = /(http.+)\',/.match(page.at(LOGOUT_REGEX)['href'])[1]
	# agent.get(URI.decode(logout_url))
end

process
byebug ; '5'




