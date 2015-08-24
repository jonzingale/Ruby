# !/usr/bin/env ruby
require (File.expand_path('./listing', File.dirname(__FILE__)))
require (File.expand_path('./region', File.dirname(__FILE__)))

require 'byebug'
require 'csv'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'net/smtp'
require 'active_support'

		# listing date cache.

		NOW = Date.today.freeze
		BASE_URL = 'http://santafe.craigslist.org'.freeze
		APARTMENT_URL = 'http://santafe.craigslist.org/search/apa'.freeze

		BLACKLIST_LOC = /Taos|Arroyo Seco|south ?side|Rodeo|Berino|El Potrero|Rancho Viejo|el Prado|Cuba|Mora|Condo|CR \d+|La Mesilla|Sombrillo|Alcalde|Whites City|Calle Cuesta|San Mateo|Airport|Cerrillos|Sol y Lomas|Ojo Caliente|mobile home|newcomb|Ute Park|Llano Quemado|roswell|Arroyo Hondo|Espanola|Pojoaque|Velarde|Albuquerque|Las Vegas|artesia|Chama|Nambe|AIRPORT|abq|fnm|pub|los alamos|Glorieta|Truchas|Edgewood|Cochiti Lake|cvn|cos|Chimayo|El Prado|El Rancho|Bernalillo|Abiquiu/i
		LISTINGS_SEL = './/div[@class="content"]/p[@class="row"]/span'.freeze
		NO_RESULTS_SEL = './/div[@class="noresults"]'.freeze
		NUM_LISTINGS_SEL = './/span[@class="totalcount"]'.freeze
		NEXT_BUTTON_SEL = './/a[@title="next page"]'.freeze
		ID_SEL = './/span[@class="maptag"]'.freeze
		GEOCOORDS = %w(latitude longitude).freeze
		
		LISTING_STUB = 'http://santafe.craigslist.org/apa/%s.html'.freeze
		DESIRED_HOUSES = ['725 manhattan','316 urioste']

		# a source directory off of crude. --untracked.
		FILES_PATH = File.expand_path('./..', __FILE__).freeze		
		##########
		
		def str_to_date(date)
			date_str = date.is_a?(Array) ? date.flatten[0] : date
			Date.strptime(date_str, '%m/%d/%Y')
		end

		def search(query)
			agent = Mechanize.new
			request_hash = {'max_price' => '1500', 
											'bedrooms' => '2',
										  'searchNearby' => '0', 
										  'query' => query }
		
			agent.get(APARTMENT_URL,request_hash)
		end

		BLIGHTLIST = /lease|housemate|gated|maintenance|recreation room|staff|compound|management|town ?house|the reserve|shower only|try us|deals|(vista|casa) alegre|visit us|tierra contenta/i
		BLACK_IDS = /5186903444|5185114818|5179106556/

		def process
			agent = Mechanize.new
			page = search('')

			next_button = page.at(NEXT_BUTTON_SEL)
			next_url = next_button.nil? ? nil : BASE_URL+next_button['href']

			num_listings = page.at(NUM_LISTINGS_SEL).text.to_i
			raise 'NoListings' if num_listings < 1
		
			listings = page.search(LISTINGS_SEL)

			# cleans listings via location_blacklist on location.
			# cleans listings via keywords_blacklist on summary.
			# cleans listings via ids.
			listings = listings.reject do |ls| 
				cond1 = BLACKLIST_LOC.match(ls.text)
				cond2 = BLIGHTLIST.match(ls.text)

				# it would be good to grab reposts as well. 
				cond3 = BLACK_IDS.match(ls.at('.//a')['data-id'])

				cond1 || cond2 || cond3
			end

			# code for offline mode, though still no geocodes.
			# 			# some_listing = agent.get(LISTING_STUB % listings_data[5]['id'])
			# 			file = File.open(FILES_PATH+'/some_listing.html')
			#    		listing = '' ; file.each { |line| listing << line }
			#    		listing = Nokogiri.parse(listing)

			# testing and building location
			listings_objs = listings.map{|ls| Listing.new(ls) }

			# At this point we check to see if any listing['loc']
			# is an address. If so, we check that it is inside the region.
			listings_data = listings_objs.inject([]) do |good, listing|
				listing.update_loc

				# verify somehow that we aren't throwing out good posts.
				# maybe make a false posting.
				if listing.has_coords?
					coords = listing.value['coords'].values
					place = Region.new(*coords)
					inside = place.in_region?
				end

				# opens listing in browser.
				# if inside || inside.nil?
				#   `open "http://santafe.craigslist.org/apa/#{listing.value['id']}.html"`
				# end

				inside == false ? good : good << listing
			end


			it = listings_data.map(&:value)
			byebug

		# below this line, we start working inside of the
		# the listings. better geocodes and body regex.

		end


process

