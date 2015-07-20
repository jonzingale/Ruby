# !/usr/bin/env ruby
require 'byebug'
require 'csv'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'net/smtp'
require 'active_support'
require 'geocoder'
require 'matrix'

module Craigslist
	class CraigslistGeocoder
		NOW = Date.today.freeze
		BASE_URL = 'http://santafe.craigslist.org'.freeze
		APARTMENT_URL = 'http://santafe.craigslist.org/search/apa'.freeze
		RECORD_HEADERS = %w(id name number rooms stove rent url reply_to).freeze
		LISTINGS_SEL = './/div[@class="content"]/p[@class="row"]/span'.freeze
		NO_RESULTS_SEL = './/div[@class="noresults"]'.freeze
		NUM_LISTINGS_SEL = './/span[@class="totalcount"]'.freeze
		NEXT_BUTTON_SEL = './/a[@title="next page"]'.freeze
		LOCATION_SEL = './/span[@class="pnr"]/small'.freeze
		HOUSING_SEL = './/span[@class="housing"]'.freeze
		PRICE_SEL = './/span[@class="price"]'.freeze
		ID_SEL = './/span[@class="maptag"]'.freeze

		BUCKMAN =  [35.698446,-105.982901].freeze
		MY_HOUSE = [35.680067,-105.962163].freeze
		ST_JOHNS = [35.671955,-105.913378].freeze

		def self.get_page(query)
			agent = Mechanize.new
			request_hash = {'max_price' => '1500', 'bedrooms' => '3',
										  'searchNearby' => '0', 'query' => query }
			agent.get(APARTMENT_URL,request_hash)
		end
		
		# returns 0.21564558001485087 of a mile which is correct
		# CraigslistGeocoder.dist('1410 hickox street santa fe new mexico', 
															# '1115 Hickox St santa fe new mexico')
		def self.dist(add_str1,add_str2) # Address(String) x Address(String) -> Float
			places = [add_str1,add_str2].map { |p| Geocoder.search(p) }
		
			unless places.any?{|p|p.empty?}
				lat1, lon1 = %w(lat lng).map do |i|
					places[0].first.data['geometry']['location'][i]
				end
			
				lat2, lon2 = %w(lat lng).map do |i|
					places[1].first.data['geometry']['location'][i]
				end
			
				phi1, phi2 = [lat1, lat2].map{|d| d * Math::PI / 180 } # in radians
				d_phi, d_lam = [lat2 - lat1, lon2 - lon1].map{|x| x * Math::PI / 180 }
			
				arc = Math.sin(d_phi/2.0) * Math.sin(d_phi/2.0) +
				    	Math.cos(phi1) * Math.cos(phi2) *
				    	Math.sin(d_lam/2.0) * Math.sin(d_lam/2.0)
			
				cir = 2 * Math.atan2(Math.sqrt(arc), Math.sqrt(1-arc))
				distance = 3959 * cir # in miles
			end
		end
#####
		COORDS = [BUCKMAN,MY_HOUSE,ST_JOHNS].freeze
		VECTS = COORDS.map{|v|Vector.elements(v)}.freeze

		def self.orth(vect) ; x,y = vect.to_a ; Vector.elements([-y,x]) ; end
		def self.inner(vect,wect)
			[vect,wect].map(&:to_a).transpose.map{|p| p.inject(1,:*)}.inject(0,:+)
		end
	
		def self.inside?(point) # GEOCOORDS -> STRING
			b, a, c = VECTS ; pt = Vector.elements(point) - a

			# perpendiculars have opposite signs.
			acute_cond =  inner(b - a, orth(a - c)) > 0
			_B = inner(pt, orth(b - a)) > 0
			_C = inner(pt, orth(a - c)) > 0
			cond = acute_cond ? _B & _C : _B | _C
	
			puts "#{cond ? 'inside' : 'outside' }" 
		end
#####
		def self.process
			page = get_page('')
			listings = page.search(LISTINGS_SEL)
		
			num_listings = page.at(NUM_LISTINGS_SEL).text.to_i
			raise 'NoListings' if num_listings < 1
		
			next_button = page.at(NEXT_BUTTON_SEL)
			next_url = next_button.nil? ? nil : BASE_URL+next_button['href']
		
			listings_data = listings.map do |ls| ; data = Hash.new
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
		
			it = listings_data.map{|r|r['loc']}.compact.take(14).map do |t|
				[t+", santa fe, nm",dist(t,'santa fe, nm')]
			end
		
			it.map{|t| puts"#{t}"}
		
			byebug ; 4
		end
	end
	# CraigslistGeocoder.process
end
