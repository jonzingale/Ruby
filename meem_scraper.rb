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
# Bibliography ; Ralf's app?
# Extend this to handle my own books as well.

# who was renewed?
# who wasn't?

DUE_WINDOW = 5.freeze
NOW = Date.today.freeze
BASE_URL = 'http://stjohnsnm.ipac.dynixasp.com/ipac20/ipac.jsp?profile=meem'.freeze
SESSION_URL =(BASE_URL+"&session=%s&menu=account").freeze
SESSION_SEL = './/input[@name="session"]'.freeze

BOOKINFO_INIT = "\nCurrently, the following items are out:".freeze
EXPIRATION_COL_SEL = './/a[@class="normalBlackFont2"]/parent::td'.freeze
BOOK_SEL = './/table[@class="tableBackgroundHighlight"]//table[@class="tableBackground"]/parent::td/parent::tr'.freeze
BOOK_HEADERS = %w(renew_key book author library_of_congress checked_out due renewed).freeze
DATA_HEADERS = %w(CARD_EXPIRATION NEXT_DUE CHECK_TODAY).freeze
DATA_KEYS = [:expiration, :next_due, :check_today]
RENEW_TEXT = "\nYour books have %sbeen renewed".freeze
TITLE_SEL = './/a[@class="mediumBoldAnchor"]'.freeze
RENEW_KEYS = './/input[@name="renewitemkeys"]'.freeze
BOOKDATA_SEL = %w(book author due renewed).freeze
AUTHOR_REGEX = /by (.+), \d*/.freeze

# a source directory off of crude. --untracked.
FILES_PATH = File.expand_path('./../../src/meem_library', __FILE__).freeze

csv = CSV.read("#{FILES_PATH}/meem_inits.csv") ; keys = [:borrower_id, :email1, :email2]
INITS_HASH = keys.zip(csv.last).inject({}){|h,kv| h.merge({kv[0] => kv[1]}) }.freeze

class Book
	attr_reader :renew_key, :title, :author, :id,
							:check_out, :due, :renewed, :book_data

	def initialize(record)
		@book_data = record.search('.//a').map(&:text)
		@title, @author, @id, @check_out, @due, @renewed = @book_data
		@author = AUTHOR_REGEX.match(@author)[1] unless @author.nil?
		key_cond = (rk = record.at(RENEW_KEYS)).nil?
		@renew_key = rk['value'] unless key_cond
	end
end

def get_book_data(page)
	# items_page =	Nokogiri::HTML(open("#{FILES_PATH}/items_out.html"))
	ts = /ts=(\d+)/.match(page.at('.//a[@title="Checked Out"]')['href'])[1]
	form = page.forms.first
	form['submenu'] = 'itemsout'
	form['ts'] = ts
	items_page = form.submit

	items_page.search(BOOK_SEL).map {|book| Book.new(book)}
end

def str_to_date(date)
	date_str = date.is_a?(Array) ? date.flatten[0] : date
	Date.strptime(date_str, '%m/%d/%Y')
end

def email_builder
	file = File.open(FILES_PATH+'/library_notification_template.txt')
	message = '' ; file.each { |line| message << line }

	cache_data = read_csv('data_cache.csv', DATA_KEYS).values.flatten
	date_info = "\nexpiration: %s    next_due: %s\n" % (cache_data[0..1])

	books = read_csv('items_out.csv', BOOK_HEADERS)
	book_data = BOOKDATA_SEL.map{|k| books[k]}.compact.map(&:flatten)
 	book_info = book_data.inject(''){|s,b| s += ("\n'%s' '%s' %s %s"  % b) }

	content = "%s%s%s" % [RENEW_TEXT % @renew_msg, @exp_msg, date_info]
	books_out = BOOKINFO_INIT + book_info + "\n\n"

	message = message % (content + books_out)

	[:email1,:email2].each do |email_key| # port 25 is likely blocked :(
		%x(echo "#{message}" | mail -s 'meem_notifier' #{INITS_HASH[email_key]})
	end
end

# csv handling
def hash_to_csv(file_name, key_values, headers)
	file = "#{FILES_PATH}/#{file_name}" # :: String x [Hash] x [String] -> [Hash]
  CSV.open(file, 'w'){|csv| csv << headers.map(&:upcase) }

	CSV.open(file, 'a') do |csv|
		data_type = key_values.first.class == Book ? :book_data : :values
		key_values.map(&data_type).each {|line| csv << [line].flatten}
	end
end

def read_csv(file_name, keys)# :: String x [Symbol] -> [Hash]
	csv = CSV.read("#{FILES_PATH}/#{file_name}")
  keys.zip(csv.drop(1).transpose).inject({}){|h,kv| h.merge({kv[0] => kv[1]}) }
end
# #

# we enter this loop if expiration date is passed
def expiration_path(next_expires,page,data_cache)
	if (expires_cond = next_expires <= NOW + 3)
		puts "\n\nEXPIRATION PATH\n\n"
		# info_page =	Nokogiri::HTML(open("#{FILES_PATH}/info.html"))
		session = /ts=(\d+)/.match(page.at('.//a[@title="Profile"]')['href'])[1]
		form = page.forms.first ; form['submenu'] = 'info' ; form['ts'] = session
		info_page = form.submit

		expires_td = info_page.search(EXPIRATION_COL_SEL).detect{|a|a.text =~/expires/i}
		next_expires = [expires_td.at('.//following-sibling::td').text]

		expire_msg_cond = next_expires == data_cache[:expiration]
		@exp_msg = expire_msg_cond ? "\nyour card is sooooo expired" : ''

		data_cache[:expiration] = next_expires
		data_cache = hash_to_csv('data_cache.csv', [data_cache], DATA_HEADERS)
	end
end

def renewal_path(next_due,page,data_cache)
	if (renew_cond = NOW > next_due - DUE_WINDOW)
		puts "\n\nRENEW PATH\n\n"

		book_data = get_book_data(page)
		# renew loop: get renew_keys for books due within the 5 days.
		books_due = book_data.select{|book| str_to_date(book.due) - NOW < DUE_WINDOW}

		renew_keys = books_due.each do |book|
			get_book_data(page)
			form = page.forms.first
			form['renewitemkeys'] = book.renew_key
			form['renewitems'] = 'Renew'
			page = form.submit
		end
		# #

		# stores new items_out
		book_data = get_book_data(page)
		hash_to_csv('items_out.csv',book_data, BOOK_HEADERS)

		# stores todays date and breaks out if book_data is empty
		if book_data.empty?
			data_cache[:check_today] = Date.today.strftime('%m/%d/%Y')
		else
			# stores new data_cache
			next_due = book_data.min_by{|data| str_to_date(data.due)}.due
			data_cache[:next_due] = [next_due]

			# renew_msg_cond == true => renew must have failed
			renew_msg_cond = NOW > str_to_date(next_due) - DUE_WINDOW
			@renew_msg = RENEW_TEXT % (renew_msg_cond ? 'not' : '')
		end

		data_cache = hash_to_csv('data_cache.csv', [data_cache], DATA_KEYS)
	end
end

def land_meem_library
	agent = Mechanize.new
	landing_page = agent.get(BASE_URL)
	session = URI.encode(landing_page.at(SESSION_SEL)['value'])

	form = agent.get(session_url = SESSION_URL % session).forms.first
	form['sec1'] = INITS_HASH[:borrower_id]
	page = form.submit
end

def process
	agent = Mechanize.new
	landing_page = agent.get(BASE_URL)
	session = URI.encode(landing_page.at(SESSION_SEL)['value'])

	form = agent.get(session_url = SESSION_URL % session).forms.first
	form['sec1'] = INITS_HASH[:borrower_id]
	page = form.submit

	data_cache = read_csv('data_cache.csv', DATA_KEYS)

 	# expiration
	next_expires = str_to_date(data_cache[:expiration])
	expiration_path(next_expires,page,data_cache)

	# renew conditions
	next_due = str_to_date(data_cache[:next_due])
	renewal_path(next_due,page,data_cache)

	# log out
	form['logout'] = 'true'
	page = form.submit

	# email
	email_builder
end

def check_today
	data_cache = read_csv('data_cache.csv', DATA_KEYS)
	str_to_date(data_cache[:check_today]) < Date.today
end

def should_i_run?
	data_cache = read_csv('data_cache.csv', DATA_KEYS)
	next_expires, next_due, no = DATA_KEYS.map{|k|str_to_date(data_cache[k][0])}
	next_expires <= NOW + 3 || NOW > next_due - DUE_WINDOW
end

if should_i_run? && check_today
	puts "I should run"
	process
end
