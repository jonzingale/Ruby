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

module Craigslist
	class CraigslistForager
		DUE_WINDOW = 5.freeze
		NOW = Date.today.freeze
		BASE_URL = 'http://santafe.craigslist.org'.freeze
		APARTMENT_URL = 'http://santafe.craigslist.org/search/apa'.freeze
		RECORD_HEADERS = %w(id name number rooms stove rent url reply_to).freeze
		DESIRED_HOUSES = ['725 manhattan','316 urioste']
		# a source directory off of crude. --untracked.
		FILES_PATH = File.expand_path('./..', __FILE__).freeze
		# records_file = CSV.read("#{FILES_PATH}/craigslist_records.csv") ; 
		
		BUCKMAN =  [35.698446,-105.982901]
		MY_HOUSE = [35.680067,-105.962163]
		ST_JOHNS = [35.671955,-105.913378]
		##########
		keys = [:borrower_id, :email1, :email2]
		# INITS_HASH = keys.zip(records_file.last).inject({}){|h,kv| h.merge({kv[0] => kv[1]}) }.freeze
		
		def self.str_to_date(date)
			date_str = date.is_a?(Array) ? date.flatten[0] : date
			Date.strptime(date_str, '%m/%d/%Y')
		end
		
		
		def self.email_builder
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
		
		# csv handling
		def hash_to_csv(file_name, key_values, headers)
			file = "#{FILES_PATH}/#{file_name}" # :: String x [Hash] x [String] -> [Hash]
		  CSV.open(file, 'w'){|csv| csv << headers.map(&:upcase) }
			CSV.open(file, 'a'){|csv| key_values.map(&:values).each{|line| csv << [line].flatten}}
		end
		
		def read_csv(file_name, keys)# :: String x [Symbol] -> [Hash]
			csv = CSV.read("#{FILES_PATH}/#{file_name}")
		  keys.zip(csv.drop(1).transpose).inject({}){|h,kv| h.merge({kv[0] => kv[1]}) }
		end
		# #
		
		# we enter this loop if expiration date is passed
		def expiration_path(next_expires,page,data_cache)
			if (expires_cond = next_expires <= NOW + 30)
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
		
		def get_book_data(page)
			# items_page =	Nokogiri::HTML(open("#{FILES_PATH}/items_out.html"))
			ts = /ts=(\d+)/.match(page.at('.//a[@title="Checked Out"]')['href'])[1]
			form = page.forms.first ; form['submenu'] = 'itemsout' ; form['ts'] = ts
			items_page = form.submit
		
			items_page.search(BOOK_SEL).inject([]) do |data, book|; row = {}
				row[:renew_key] =  book.at('.//input[@name="renewitemkeys"]')['value']
				row[:title] = /(.+)\/?/.match(book.at(TITLE_SEL).text)[1]
				row[:author] = /by (.+), \d*/.match(book.search('.//a')[1].text)[1]
				row[:id] = book.search('.//a')[2].text
				row[:check_out] = book.search('.//a')[3].text
				row[:due] = book.search('.//a')[4].text
				row[:renewed] = book.search('.//a')[5].text
				data << row ; data
			end
		end
		
		def renewal_path(next_due,page,data_cache)
			if (renew_cond = NOW > next_due - DUE_WINDOW)
				puts "\n\nRENEW PATH\n\n"
		
				book_data = get_book_data(page)
				# renew loop: get renew_keys for books due within the 5 days.
				books_due = book_data.select{|book| str_to_date(book[:due]) - NOW < DUE_WINDOW}
		
				renew_keys = books_due.each do |book|
					get_book_data(page)
					form = page.forms.first
					form['renewitemkeys'] = book[:renew_key]
					form['renewitems'] = 'Renew'
					page = form.submit
				end
				# #
		
				# stores new items_out
				book_data = get_book_data(page)
		
				hash_to_csv('items_out.csv',book_data, BOOK_HEADERS)
		
				# stores new data_cache
				next_due = book_data.min_by{|data| str_to_date(data[:due])}[:due]
				data_cache[:next_due] = [next_due]
		
				# renew_msg_cond == true => renew must have failed
				renew_msg_cond = NOW > str_to_date(next_due) - DUE_WINDOW
				@renew_msg = RENEW_TEXT % (renew_msg_cond ? 'not' : '')
		
				data_cache = hash_to_csv('data_cache.csv', [data_cache], DATA_KEYS)
			end
		end
		###############
		RADII_BLACKLIST = ['sfuad'].freeze

		def self.jacobi(coords)
			center = '1410 hickox street, santa fe, new mexico'
			dist = CraigslistGeocoder.dist(coords,center)
			dist < 10
		end

		def self.search(query)
			agent = Mechanize.new
			request_hash = {'max_price' => '1500', 
											'bedrooms' => '3',
										  'searchNearby' => '0', 
										  'query' => query }
		
			agent.get(APARTMENT_URL,request_hash)
		end
		
		BLACKLIST = /Taos|Arroyo Seco|El Potrero|La Mesilla|Alcalde|Arroyo Hondo|Espanola|Pojoaque|Velarde|Las Vegas|Chama|Nambe|AIRPORT|Glorieta|Truchas|Edgewood|Cochiti Lake|El Prado|El Rancho|Bernalillo|Abiquiu/i
		LISTINGS_SEL = './/div[@class="content"]/p[@class="row"]/span'.freeze
		NO_RESULTS_SEL = './/div[@class="noresults"]'.freeze
		NUM_LISTINGS_SEL = './/span[@class="totalcount"]'.freeze
		NEXT_BUTTON_SEL = './/a[@title="next page"]'.freeze
		LOCATION_SEL = './/span[@class="pnr"]/small'.freeze
		HOUSING_SEL = './/span[@class="housing"]'.freeze
		PRICE_SEL = './/span[@class="price"]'.freeze
		ID_SEL = './/span[@class="maptag"]'.freeze
		GEOCOORDS = %w(latitude longitude).freeze
		
		LISTING_STUB = 'http://santafe.craigslist.org/apa/%s.html'.freeze
		
		def self.process
			page = search('')
			next_button = page.at(NEXT_BUTTON_SEL)
			next_url = next_button.nil? ? nil : BASE_URL+next_button['href']
		
			num_listings = page.at(NUM_LISTINGS_SEL).text.to_i
			raise 'NoListings' if num_listings < 1
		
			listings = page.search(LISTINGS_SEL)
			good_listings = listings.reject{|ls| BLACKLIST.match(ls.text)}
		
			listings_data = good_listings.map do |ls| ; data = Hash.new
			# BLACKLIST
			# we can also ls.text to regex out key notions, blacklists
			# maybe not a blacklist, but a ranking systems?!
		
		
			# #
				beds, footage = ls.at(HOUSING_SEL).text.scan(/\d+/)
				location = /\((.+)\)/.match(ls.at(LOCATION_SEL))
				price = /\d+/.match(ls.at(PRICE_SEL).text)
		
				data['id'] = ls.at('.//a')['data-id']
				data['date'] = Date.parse(ls.at('.//time')['datetime'])
				data['summary'] = ls.at('.//a').text
				data['loc'] = location[1] unless location.nil?
				data['price'] = price[0].to_i unless price.nil?
				data['beds'] = beds
				data['footage'] = footage
				data
			end
		
			# once in_side a given listing, google maps offers:
			# div id="map" data-latitude="35.639424" data-longitude="-105.965688" 
			# to select on ?! 
		
			# a particular listing
			agent = Mechanize.new
			listing = agent.get(LISTING_STUB % '5069391447')
		
			lat, long = GEOCOORDS.map{|l|listing.at('.//div[@id="map"]')["data-#{l}"].to_f}
			listing_body = listing.at('.//section[@id="postingbody"]').text

			# call the geocoder class
			it = jacobi([lat,long])
			# Geocoder.search('santa fe')
			# "lat"=>35.7540089, "lng"=>-105.894186}

			# santa fe to cougar canyon
			# lat = 0.13210890000000575
			# lng = 0.025386000000011677
byebug
		
			data_cache = read_csv('data_cache.csv', DATA_KEYS)
		
			# email
			email_builder
		end
	end

	CraigslistForager.process
end



