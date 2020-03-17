# !/usr/bin/env ruby
require 'active_support'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'date'
require 'csv'

DUE_WINDOW = 7.freeze
NOW = Date.today.freeze
FAR_FUTURE = '01/01/2030'.freeze

BASE_URL = 'http://stjohnsnm.ipac.dynixasp.com/ipac20/ipac.jsp?profile=meem'.freeze
SESSION_URL =(BASE_URL+"&session=%s&menu=account").freeze
SESSION_SEL = './/input[@name="session"]'.freeze

EXPIRATION_COL_SEL = './/a[@class="normalBlackFont2"]/parent::td'.freeze
BOOK_SEL = './/table[@class="tableBackgroundHighlight"]//table[@class="tableBackground"]/parent::td/parent::tr'.freeze

HEADERS = %w(ACCOUNT EXPIRATION NEXT_DUE HAS_RUN ACTIVE).freeze

RENEW_KEYS = './/input[@name="renewitemkeys"]'.freeze
AUTHOR_REGEX = /by (.+), \d*/.freeze
EDITOR_REGEX = /by\] (.+) \;/.freeze

# a source directory off of crude. --untracked.
FILES_PATH = File.expand_path('./../data', __FILE__).freeze
MEEM_INITS = "#{FILES_PATH}/meem_inits.csv".freeze

class USER
	attr_accessor :id, :expiration, :next_due, :has_run, :active

	def initialize(user_data)
		@id = user_data['ACCOUNT']
		@expiration = user_data['EXPIRATION']
		@next_due = user_data['NEXT_DUE']
		@has_run = user_data['HAS_RUN'] == 'true'
		@active = user_data['ACTIVE'] == 'true'
	end
end

class Book
	attr_reader :renew_key, :title, :author, :id,
							:check_out, :due, :renewed, :book_data

	def initialize(record)
		@book_data = record.search('.//a').map(&:text)
		@title, @author, @id, @check_out, @due, @renewed = @book_data
		if @author.ord == 160
			@author = EDITOR_REGEX.match(record.text)[1]
		else
			@author = AUTHOR_REGEX.match(@author).nil? ? '' : $1
		end
		key_cond = (rk = record.at(RENEW_KEYS)).nil?
		@renew_key = rk['value'] unless key_cond
	end
end

def clean_string(string)
	string.split.select{|t|t.ascii_only?}.join(' ')
end

def get_book_data(page)
	# items_page =	Nokogiri::HTML(open("#{FILES_PATH}/items_out.html")) # for testing
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
# #

# we enter this loop if expiration date has passed
def expiration_path(page, user)
	next_expires = str_to_date(user.expiration)

	if (expires_cond = next_expires <= NOW + 3)
		puts "\n\nEXPIRATION PATH\n\n"

		session = /ts=(\d+)/.match(page.at('.//a[@title="Profile"]')['href'])[1]
		form = page.forms.first ; form['submenu'] = 'info' ; form['ts'] = session
		info_page = form.submit
		# info_page =	Nokogiri::HTML(open("#{FILES_PATH}/expiration.html")) # for testing.

		expires_col = info_page.search(EXPIRATION_COL_SEL)
		expires_td = expires_col.detect { |a| a.text =~/expires/i }
		user.expiration = expires_td.at('.//following-sibling::td').text

		expire_msg_cond = str_to_date(user.expiration) < NOW
		print(expire_msg_cond ? "\nCheck your expiration date!!" : '')
	end
end

def print_book_data(books, user)
	puts "book data for user #{user.id}\n"
	books.each do |book|
		puts "#{book.title} by #{book.author} is due #{book.due}.\n"
		puts "The book has been renewed #{book.renewed} times.\n\n"
	end
end

def renewal_path(page, user)
	next_due = str_to_date(user.next_due)

	if (renew_cond = NOW > next_due - DUE_WINDOW)
		print("\n\nRENEW PATH\n\n")

		book_data = get_book_data(page)

		# renew loop: get renew_keys for books due within the 5 days.
		books_due = book_data.select do |book|
			str_to_date(book.due) - NOW < DUE_WINDOW
		end

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

		# updates record
		if book_data.any?
			print_book_data(book_data, user)
			next_due = book_data.min_by{|book| str_to_date(book_data[0].due)}.due
			user.next_due = next_due

			renew_msg_cond = NOW > str_to_date(user.next_due) - DUE_WINDOW
			@renew_msg = renew_msg_cond ? 'Renewal Failed!!' : 'Books Renewed'
		end

		# Notes that program has run for User
		user.has_run = true
	end
end

def process(user)
	agent = Mechanize.new
	landing_page = agent.get(BASE_URL)
	session = URI.encode(landing_page.at(SESSION_SEL)['value'])
	form = agent.get(session_url = SESSION_URL % session).forms.first
	form['sec1'] = user.id
	page = form.submit # overview page
 	# page =	Nokogiri::HTML(open("#{FILES_PATH}/info.html")) # for testing.

 	# check and update expiration conditions
	expiration_path(page, user)

	# check and update renewal conditions
	renewal_path(page, user)

	# # log out
	form['logout'] = 'true'
	page = form.submit
end

# TODO: rewrite with correct implementation of headers
def updateUsers(users)
  users.each do |user|
		CSV.open(MEEM_INITS, 'w', write_headers: HEADERS) do |csv|
			csv << [user.id, user.expiration, user.next_due,
							user.has_run, user.active]
		end
	end
end

def should_run?(user)
	next_expires = str_to_date(user.expiration)
	next_due = str_to_date(user.next_due)

	next_expires <= NOW + 3 || NOW > next_due - DUE_WINDOW
end

def read_csv(file_name)
	csv = CSV.read(MEEM_INITS, headers: true, return_headers: false)
end

def meem_library_main # Check each Account and Renew if Necessary.
	users = read_csv('meem_inits.csv').map { |record| USER.new(record) }
	users.each do |user|
		if user.active && !user.has_run && should_run?(user)
			puts "I should run"
			process(user)
		end
	end

	updateUsers(users)
end

meem_library_main