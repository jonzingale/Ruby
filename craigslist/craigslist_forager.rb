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

		RADII_BLACKLIST = ['sfuad'].freeze
		# APARTMENT_URL = 'http://santafe.craigslist.org/apa/5184025942.html'
# http://santafe.craigslist.org/apa/5179106556.html
		BLACKLIST_LOC = /Taos|Arroyo Seco|El Potrero|La Mesilla|Alcalde|Whites City|Calle Cuesta|San Mateo|Airport|Cerrillos|Sol y Lomas|Ojo Caliente|mobile home|newcomb|Ute Park|Llano Quemado|roswell|Arroyo Hondo|Espanola|Pojoaque|Velarde|Albuquerque|Las Vegas|artesia|Chama|Nambe|AIRPORT|abq|fnm|pub|los alamos|Glorieta|Truchas|Edgewood|Cochiti Lake|cvn|cos|Chimayo|El Prado|El Rancho|Bernalillo|Abiquiu/i
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

		# RECORD_HEADERS = %w(id name number rooms stove rent url reply_to).freeze
		DESIRED_HOUSES = ['725 manhattan','316 urioste']
		# a source directory off of crude. --untracked.
		FILES_PATH = File.expand_path('./..', __FILE__).freeze
		# records_file = CSV.read("#{FILES_PATH}/craigslist_records.csv") ; 
		
		BUCKMAN =  [35.698446,-105.982901]
		MY_HOUSE = [35.680067,-105.962163]
		ST_JOHNS = [35.671955,-105.913378]
		##########
		
		def self.str_to_date(date)
			date_str = date.is_a?(Array) ? date.flatten[0] : date
			Date.strptime(date_str, '%m/%d/%Y')
		end

		def self.jordan(coords)
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
		
		def self.process
			page = search('')

			next_button = page.at(NEXT_BUTTON_SEL)
			next_url = next_button.nil? ? nil : BASE_URL+next_button['href']

			num_listings = page.at(NUM_LISTINGS_SEL).text.to_i
			raise 'NoListings' if num_listings < 1
		
			listings = page.search(LISTINGS_SEL)
			good_listings = listings.reject{|ls| BLACKLIST_LOC.match(ls.text)}
		
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

			# will open all listings that have made it this far.
			# listings_data.each{|i|`open "http://santafe.craigslist.org/apa/#{i['id']}.html"`}

byebug
			# once in_side a given listing, google maps offers:
			# div id="map" data-latitude="35.639424" data-longitude="-105.965688" 
			# to select on ?! 
		
			# a particular listing
			agent = Mechanize.new
			listing = agent.get(LISTING_STUB % '5069391447')
byebug
			lat, long = GEOCOORDS.map{|l|listing.at('.//div[@id="map"]')["data-#{l}"].to_f}
			listing_body = listing.at('.//section[@id="postingbody"]').text

			# call the geocoder class
			it = jordan([lat,long])
			# "lat"=>35.7540089, "lng"=>-105.894186}
		end
	end

	CraigslistForager.process
end



