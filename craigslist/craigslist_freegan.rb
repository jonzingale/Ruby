# !/usr/bin/env ruby
require (File.expand_path('./craigslist_geocoder', File.dirname(__FILE__)))
require 'byebug'
require 'csv'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'net/smtp'
require 'active_support'

	DUE_WINDOW = 5.freeze
	NOW = Date.today.freeze
	BASE_URL = 'http://santafe.craigslist.org'.freeze
	FREE_URL = 'http://santafe.craigslist.org/search/zip'.freeze
	LISTING_STUB = 'http://santafe.craigslist.org/zip/%s.html'.freeze
	LISTINGS_SEL = './/div[@class="content"]/p[@class="row"]/span'.freeze
	NUM_LISTINGS_SEL = './/span[@class="totalcount"]'.freeze
	NO_RESULTS_SEL = './/div[@class="noresults"]'.freeze
	NEXT_BUTTON_SEL = './/a[@title="next page"]'.freeze
	LOCATION_SEL = './/span[@class="pnr"]/small'.freeze
	GEOCOORDS = %w(latitude longitude).freeze

	# include number of miles willing to travel for thing.
	DESIREABLES = []

	# a source directory off of crude. --untracked.
	FILES_PATH = File.expand_path('./..', __FILE__).freeze
	# records_file = CSV.read("#{FILES_PATH}/craigslist_records.csv") ; 

	##########
	keys = [:borrower_id, :email1, :email2]	

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
		book_data = BOOKDATA_SEL.map{|k|books[k]}.transpose.map(&:flatten)
	 	book_info = book_data.inject(''){|s,b| s += ("\n'%s' '%s' %s %s"  % b) }
	
		content = "%s%s%s" % [RENEW_TEXT % @renew_msg, @exp_msg, date_info]
		books_out = BOOKINFO_INIT + book_info + "\n\n"
	
		message = message % (content + books_out)
	
		[:email1,:email2].each do |email_key| 
			# %x(echo '#{message}' | mail -s 'meem_notifier' #{INITS_HASH[email_key]})
		end
	end
	
	###############

	def process
		agent = Mechanize.new
		page = agent.get(FREE_URL)
		next_button = page.at(NEXT_BUTTON_SEL)
		next_url = next_button.nil? ? nil : BASE_URL+next_button['href']
	
		num_listings = page.at(NUM_LISTINGS_SEL).text.to_i
		raise 'NoListings' if num_listings < 1
	
		listings = page.search(LISTINGS_SEL)

		# maybe based on distance?
		# good_listings = listings.reject{|ls| BLACKLIST.match(ls.text)}

		listings_data = listings.map do |ls| ; data = Hash.new
			location = /\((.+)\)/.match(ls.at(LOCATION_SEL))
			data['summary'] = ls.at('.//a').text
			data['loc'] = location[1] unless location.nil?
			data['date'] = Date.parse(ls.at('.//time')['datetime'])
			data['id'] = ls.at('.//a')['data-id']
			data
		end

byebug
	# in a listing.
		page = agent.get(LISTING_STUB % listings_data[0]['id'])
		lat, long = GEOCOORDS.map{|l|page.at('.//div[@id="map"]')["data-#{l}"].to_f}
		listing_body = page.at('.//section[@id="postingbody"]').text
byebug
		# email
		email_builder
	end

process