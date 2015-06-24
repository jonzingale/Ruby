# !/usr/bin/env ruby
require 'byebug'
require 'csv'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'net/smtp'
require 'active_support'
# TODO: 
#  Bibliography

NOW = Date.today.freeze
BASE_URL = 'http://stjohnsnm.ipac.dynixasp.com/ipac20/ipac.jsp?profile=meem'.freeze
SESSION_URL =(BASE_URL+"&session=%s&menu=account").freeze
SESSION_SEL = './/input[@name="session"]'.freeze

BOOKINFO_INIT = "\nCurrently, the following items are out:".freeze
EXPIRATION_COL_SEL = './/a[@class="normalBlackFont2"]/parent::td'.freeze
BOOK_SEL = './/table[@class="tableBackgroundHighlight"]//table[@class="tableBackground"]/parent::td/parent::tr'.freeze
BOOK_HEADERS = %w(renew_key book author library_of_congress checked_out due renewed).freeze
DATA_HEADERS = %w(CARD_EXPIRATION NEXT_DUE ADDRESSEE1 ADDRESSEE2).freeze
DATA_KEYS = [:expiration, :next_due, :addressee1, :addressee2]
RENEW_TEXT = "\nYour books have %sbeen renewed".freeze
TITLE_SEL = './/a[@class="mediumBoldAnchor"]'.freeze
BOOKDATA_SEL = %w(book author due renewed).freeze

# a source directory off of crude. --untracked.
FILES_PATH = File.expand_path('./../../src/meem_library', __FILE__).freeze

csv = CSV.read("#{FILES_PATH}/meem_inits.csv") ; keys = [:borrower_id, :email]
INITS_HASH = keys.zip(csv.last).inject({}){|h,kv| h.merge({kv[0] => kv[1]}) }.freeze

def str_to_date(date_str) ; Date.strptime(date_str[0], '%m/%d/%Y') ; end

def should_i_run?
	data_cache = read_csv('data_cache.csv', DATA_KEYS)
	next_expires, next_due = DATA_KEYS[0..1].map{|k|str_to_date(data_cache[k])}
	next_expires <= NOW + 30 || NOW > next_due - 5
end

def email_builder
	file = File.open(FILES_PATH+'/library_notification_template.txt')
	message = '' ; file.each { |line| message << line }

	cache_data = read_csv('data_cache.csv', DATA_KEYS).values.flatten
	date_info = "\nexpiration: %s    next_due: %s\n" % (cache_data[0..1])

	books = read_csv('items_out.csv', BOOK_HEADERS)
	book_data = BOOKDATA_SEL.map{|k|books[k]}.transpose.map(&:flatten)
 	book_info = book_data.inject(''){|s,b| s += ("\n'%s' '%s' %s %s"  % b) }

	content = "%s%s%s" % [RENEW_TEXT % @renew_msg, @exp_msg, date_info]
	books_out = BOOKINFO_INIT + book_info + "\n\n"

	message = message % (content + books_out)

	cache_data[2..3].each do |address| 
		%x(echo '#{message}' | mail -s 'meem_notifier' #{address})
	end
end

# csv handling
def hash_to_csv(file_name, key_values, headers)
	file = "#{FILES_PATH}/#{file_name}" # :: String x [Hash] x [String] -> [Hash]
  CSV.open(file, 'w'){|csv| csv << headers.map(&:upcase) }
	CSV.open(file, 'a'){|csv| key_values.map(&:values).each{|line| csv << line }}
end

def read_csv(file_name, keys)# :: String x [Symbol] -> [Hash]
	csv = CSV.read("#{FILES_PATH}/#{file_name}")
  keys.zip(csv.drop(1).transpose).inject({}){|h,kv| h.merge({kv[0] => kv[1]}) }
end
# #

def expiration_path(next_expires,page,data_cache)
	if (expires_cond = next_expires <= NOW + 30)
		# info_page =	Nokogiri::HTML(open("#{FILES_PATH}/info.html"))
		session = /ts=(\d+)/.match(page.at('.//a[@title="Profile"]')['href'])[1]
		form = page.forms.first ; form['submenu'] = 'info' ; form['ts'] = session
		info_page = form.submit

		expires_td = info_page.search(EXPIRATION_COL_SEL).detect{|a|a.text =~/expires/i}
		next_expires = expires_td.at('.//following-sibling::td').text

		expire_msg_cond = next_expires == data_cache[:expiration]
		@exp_msg = expire_msg_cond ? "\nyour card is sooooo expired" : ''

		data_cache[:expiration] = next_expires
		data_cache = hash_to_csv('data_cache.csv', [data_cache], DATA_HEADERS)
	end
end

def renewal_path(next_due,page,data_cache)
	if (renew_cond = NOW > next_due - 5)
		# items_page =	Nokogiri::HTML(open("#{FILES_PATH}/items_out.html"))
		ts = /ts=(\d+)/.match(page.at('.//a[@title="Checked Out"]')['href'])[1]
		form = page.forms.first ; form['submenu'] = 'itemsout' ; form['ts'] = ts
		items_page = form.submit

		book_data = items_page.search(BOOK_SEL).inject([]) do |data, book|; row = {}
			row[:renew_key] =  book.at('.//input[@name="renewitemkeys"]')['value']
			row[:title] = /(.+)\//.match(book.at(TITLE_SEL).text)[1]
			row[:author] = /by (.+), \d*/.match(book.search('.//a')[1].text)[1]
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

		# renew_msg_cond == true => renew must have failed
		renew_msg_cond = NOW > str_to_date(next_due) - 5
		@renew_msg = RENEW_TEXT % (renew_msg_cond ? 'not' : '')

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
end

def process
	# land meem library
	agent = Mechanize.new
	landing_page = agent.get(BASE_URL)
	session = URI.encode(landing_page.at(SESSION_SEL)['value'])

	form = agent.get(session_url = SESSION_URL % session).forms.first
	form['sec1'] = INITS_HASH[:borrower_id]
	page = form.submit
	# #

	data_cache = read_csv('data_cache.csv', DATA_KEYS)

  # expiration
	next_expires = str_to_date(data_cache[:expiration])
	expiration_path(next_expires,page,data_cache)
	# #

	# renew conditions
	next_due = str_to_date(data_cache[:next_due])
	renewal_path(next_due,page,data_cache)
	# #

	# log out
	form['logout'] = 'true'
	page = form.submit
	# #

	# email
	email_builder
end

(puts "I should run") if should_i_run?
process if should_i_run?
