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
		BUCKMAN =  [35.698446,-105.982901]
		MY_HOUSE = [35.680067,-105.962163]
		ST_JOHNS = [35.671955,-105.913378]
		COORDS = [BUCKMAN,MY_HOUSE,ST_JOHNS].freeze

		def self.jacobi(coords,miles) ; coord_dist(MY_HOUSE,coords) < miles ; end

		def self.coord_dist(here_coords,there_coords) # COORDS -> COORDS -> FLOAT
			unless (places = [here_coords,there_coords]).any?(&:empty?)
				lat1, lon1, lat2, lon2 = places.flatten

				phi1, phi2 = [lat1, lat2].map{|d| d * Math::PI / 180 } # in radians
				d_phi, d_lam = [lat2 - lat1, lon2 - lon1].map{|x| x * Math::PI / 180 }
			
				arc = Math.sin(d_phi/2.0) * Math.sin(d_phi/2.0) +
				    	Math.cos(phi1) * Math.cos(phi2) *
				    	Math.sin(d_lam/2.0) * Math.sin(d_lam/2.0)
			
				cir = 2 * Math.atan2(Math.sqrt(arc), Math.sqrt(1-arc))
				distance = 3959 * cir # in miles
			end
		end

		# returns 0.21564558001485087 of a mile which is correct
		# CraigslistGeocoder.dist('1410 hickox street santa fe new mexico', 
															# '1115 Hickox St santa fe new mexico')
		# {"lat"=>35.67871801970851, "lng"=>-105.9635119802915}

		def self.dist(add_str1,add_str2) # Address(String) x Address(String) -> Float
			places = [add_str1,add_str2].map { |p| Geocoder.search(p) }
			unless places.any?{|p|p.empty?}
				coords = places.map{|p|%w(lat lng).map{|i|p.first.data['geometry']['location'][i]}}
				coord_dist(*coords)
			end
		end

		#####
		def self.orth(vect) ; x,y = vect.to_a ; Vector.elements([-y,x]) ; end
		def self.inner(vect,wect)
			[vect,wect].map(&:to_a).transpose.map{|p| p.inject(1,:*)}.inject(0,:+)
		end
	
		def self.inside?(point) # GEOCOORDS -> STRING
			b, a, c = COORDS.map{|v|Vector.elements(v)}
			pt = Vector.elements(point) - a

			# perpendiculars have opposite signs.
			acute_cond =  inner(b - a, orth(a - c)) > 0
			_B = inner(pt, orth(b - a)) > 0
			_C = inner(pt, orth(a - c)) > 0
			cond = acute_cond ? _B & _C : _B | _C
	
			puts "#{cond ? 'inside' : 'outside' }" 
		end
		#####

		def self.process
			close = CraigslistGeocoder.coord_dist(ST_JOHNS,MY_HOUSE)
			byebug ; 4
		end
	end
	# uncomment when testing.
	# CraigslistGeocoder.process
end
