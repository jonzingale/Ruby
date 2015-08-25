# !/usr/bin/env ruby
require (File.expand_path('./listing', File.dirname(__FILE__)))
require (File.expand_path('./region', File.dirname(__FILE__)))
require 'active_support/core_ext/object/blank'
require 'active_support'
require 'mechanize'
require 'nokogiri'
require 'byebug'
require 'date'

		# listing date cache.
		NOW = Date.today.freeze
		BASE_URL = 'http://santafe.craigslist.org'.freeze
		APARTMENT_URL = 'http://santafe.craigslist.org/search/apa'.freeze
		LISTING_STUB = 'http://santafe.craigslist.org/apa/%s.html'.freeze

		BLACKLIST_LOC = /Taos|Arroyo Seco|south ?side|Rodeo|Berino|Mentmore|El Potrero|Rancho Viejo|el Prado|Cuba|Mora|Condo|CR \d+|La Mesilla|Sombrillo|Alcalde|Whites City|Calle Cuesta|San Mateo|Airport|Cerrillos|Sol y Lomas|Ojo Caliente|mobile home|newcomb|Ute Park|Llano Quemado|roswell|Arroyo Hondo|Espanola|Pojoaque|Velarde|Albuquerque|Las Vegas|artesia|Chama|Nambe|AIRPORT|abq|fnm|pub|los alamos|Glorieta|Truchas|Edgewood|Cochiti Lake|cvn|cos|Chimayo|El Prado|El Rancho|Bernalillo|Abiquiu/i
		BLIGHTLIST = /lease to|housemate|gated|maintenance|recreation room|South Meadows|staff|compound|management|town ?house|the reserve|shower only|try us|deals|(vista|casa) alegre|visit us|tierra contenta/i
		BLACK_IDS = /5186903444|5185114818|5179106556|5184025942/
		BODY_BLACKLIST = /Truchas|South Meadows/i

		LISTINGS_SEL = './/div[@class="content"]/p[@class="row"]/span'.freeze
		NUM_LISTINGS_SEL = './/span[@class="totalcount"]'.freeze
		NEXT_BUTTON_SEL = './/a[@title="next page"]'.freeze

		def open_listings(listings)
			listings.each do |listing|
		 		`open "http://santafe.craigslist.org/apa/#{listing.value['id']}.html"`
			end
		end

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

		def process
			agent = Mechanize.new
			page = search('')

			next_button = page.at(NEXT_BUTTON_SEL)
			next_url = next_button.nil? ? nil : BASE_URL+next_button['href']

			num_listings = page.at(NUM_LISTINGS_SEL).text.to_i
			raise 'NoListings' if num_listings < 1

			# cleans listings via location_blacklist on location,
			# keywords_blacklist on summary, and ids
			listings = page.search(LISTINGS_SEL).reject do |ls| 
				cond1 = BLACKLIST_LOC.match(ls.text)
				cond2 = BLIGHTLIST.match(ls.text)
				cond3 = BLACK_IDS.match(ls.at('.//a')['data-id'])

				cond1 || cond2 || cond3
			end

			# constructs and array of listings
			listings_data = listings.map{|ls| Listing.new(ls) }

			# outside pass at location determining.
			listings_data.select! do |listing|
				listing.update_loc

				inside = true
				if listing.has_coords?
					coords = listing.value['coords'].values
					place = Region.new(*coords)
					inside = place.in_region?
				end ; inside
			end

			# inside pass at location determining.
			listings_data.select! do |listing|
				page = agent.get(LISTING_STUB % listing.value['id'])
				coords = page.search('.//div[@id="map"]')

				if coords.present?
					lat = coords.attr('data-latitude').value.to_f
					lng = coords.attr('data-longitude').value.to_f
					listing.update_loc(lat,lng)
				end

				inside = true
				if listing.has_coords?
					coords = listing.value['coords'].values
					place = Region.new(*coords)
					inside = place.in_region?
				end ; inside
			end

			# body pass at location, filtering.
			listings_data.reject! do |listing|
				page = agent.get(LISTING_STUB % listing.value['id'])
				body = page.search('.//section[@id="postingbody"]').text

				# perhaps it would be good to regex_loc once more
				# from here?

				BODY_BLACKLIST.match(body) || BLIGHTLIST.match(body)
			end

			open_listings(listings_data)
			it = listings_data.map(&:value)
			byebug
		end

process

