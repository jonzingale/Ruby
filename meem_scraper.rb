# !/usr/bin/env ruby
require 'byebug'
require 'csv'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'net/smtp'
# Look in to postfix

require 'active_support'
# TODO: 
# Extend this to handle my own books as well.
# The refactoring includes extending meem_inits to include data_cache.

# who was renewed?
# who wasn't?


DUE_WINDOW = 7.freeze
NOW = Date.today.freeze
BASE_URL = 'http://stjohnsnm.ipac.dynixasp.com/ipac20/ipac.jsp?profile=meem'.freeze
SESSION_URL =(BASE_URL+"&session=%s&menu=account").freeze
SESSION_SEL = './/input[@name="session"]'.freeze

BOOKINFO_INIT = "\nCurrently, the following items are out:".freeze
EXPIRATION_COL_SEL = './/a[@class="normalBlackFont2"]/parent::td'.freeze
BOOK_SEL = './/table[@class="tableBackgroundHighlight"]//table[@class="tableBackground"]/parent::td/parent::tr'.freeze
BOOK_HEADERS = %w(renew_key book author library_of_congress checked_out due renewed).freeze
DATA_HEADERS = %w(ACCOUNT,EMAIL,EXPIRATION,NEXT_DUE,CHECK_TODAY).freeze
KEYS = [:borrower_id, :expiration, :next_due, :check_today].freeze

# DATA_KEYS = [:expiration, :next_due, :check_today]
RENEW_TEXT = "\nYour books have %sbeen renewed".freeze
TITLE_SEL = './/a[@class="mediumBoldAnchor"]'.freeze
RENEW_KEYS = './/input[@name="renewitemkeys"]'.freeze
BOOKDATA_SEL = %w(book author due renewed).freeze
AUTHOR_REGEX = /by (.+), \d*/.freeze
EDITOR_REGEX = /by\] (.+) \;/.freeze

# a source directory off of crude. --untracked.
FILES_PATH = File.expand_path('./../../src/meem_library', __FILE__).freeze

# csv = CSV.read("#{FILES_PATH}/meem_inits.csv")
FAR_FUTURE = '01/01/2030'.freeze

def initialize_data
	inits_ary = []
	CSV.foreach("#{FILES_PATH}/meem_inits.csv") do |row|
		inits_ary << KEYS.zip(row).inject({}){|h, kv| h.merge({kv[0] => kv[1]})}
	end
	inits_ary
end

INITS_HASH = initialize_data.freeze

class Book
	attr_reader :renew_key, :title, :author, :id,
							:check_out, :due, :renewed, :book_data

	def initialize(record)
		@book_data = record.search('.//a').map(&:text)
		@title, @author, @id, @check_out, @due, @renewed = @book_data
		if @author.ord == 160
			@author = EDITOR_REGEX.match(record.text)[1]
		else
			@author = (AUTHOR_REGEX.match(@author)).nil? ? '' : $1
		end
		key_cond = (rk = record.at(RENEW_KEYS)).nil?
		@renew_key = rk['value'] unless key_cond
	end
end

def clean_string(string)
	string.split.select{|t|t.ascii_only?}.join(' ')
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
	date_str = date.is_a?(Array) ? date.flatten[0] : date.strip
	next_due = date.empty? ? FAR_FUTURE : date
	Date.strptime(date_str, '%m/%d/%Y')
end

# csv handling
def hash_to_csv(file_name, key_values, headers)
	file = "#{FILES_PATH}/#{file_name}" # :: String x [Hash] x [String] -> [Hash]
  CSV.open(file, 'w'){|csv| csv << headers.map(&:upcase) }

	CSV.open(file, 'a') do |csv|
		key_values.first.class == Book ?
			key_values.book_data.transpose.each {|line| csv << line} :
				key_values.values.transpose.each {|line| csv << line}
	end
end

def read_csv(file_name, keys)# :: String x [Symbol] -> [Hash]
	csv = CSV.read("#{FILES_PATH}/#{file_name}")
  keys.zip(csv.drop(1).transpose).inject({}){|h, kv| h.merge({kv[0] => kv[1]}) }
end
# #

# we enter this loop if expiration date is passed
def expiration_path(next_expires, page, data_cache)
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


		# This is where things go wrong because
		# next_expires ought to be an array by now but isn't.
		data_cache[:expiration] = next_expires
		data_cache = hash_to_csv('meem_inits.csv', data_cache, DATA_HEADERS)
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

		data_cache = hash_to_csv('meem_inits.csv', data_cache, KEYS)
	end
end

def land_meem_library # This is a test method.
	agent = Mechanize.new
	landing_page = agent.get(BASE_URL)
	session = URI.encode(landing_page.at(SESSION_SEL)['value'])

	form = agent.get(session_url = SESSION_URL % session).forms.first
	form['sec1'] = INITS_HASH.first[:borrower_id]
	page = form.submit
end

def process(record)
	borrower_id, expires, due, today = record.values
	data_cache = read_csv('meem_inits.csv', KEYS)

	agent = Mechanize.new
	landing_page = agent.get(BASE_URL)
	session = URI.encode(landing_page.at(SESSION_SEL)['value'])
	form = agent.get(session_url = SESSION_URL % session).forms.first
	form['sec1'] = borrower_id
	page = form.submit

 	# expiration
	next_expires = str_to_date(expires)
	expiration_path(next_expires, page, data_cache)

	# renew conditions
	next_due = str_to_date(data_cache[:next_due])
	renewal_path(next_due,page,data_cache)

	# log out
	form['logout'] = 'true'
	page = form.submit
end

def check_today?(record)
	str_to_date(record[:check_today]) < Date.today
end

def should_i_run?(record)
	b_id, expires, due, today = record.values
	next_expires = str_to_date(expires)
	next_due = str_to_date(due)

	next_expires <= NOW + 3 || NOW > next_due - DUE_WINDOW
end

# Uncomment when Card is renewed.
# Check each Account and Renew if Necessary.
INITS_HASH.drop(1).each do |record|
	# if check_today?(record) && should_i_run?(record)
		puts "I should run"
		# process(record)
	# end
end
