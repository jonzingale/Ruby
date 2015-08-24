	require 'geocoder'

	class Listing
		ADDRESS_REGEX = /\d{3,} (\w+| )+/.freeze
		NOT_ADDRESS_REGEX = /(SQ|FT)/i.freeze

		LOCATION_SEL = './/span[@class="pnr"]/small'.freeze
		HOUSING_SEL = './/span[@class="housing"]'.freeze
		PRICE_SEL = './/span[@class="price"]'.freeze

		def initialize(noko_elem)
			data = Hash.new
			beds, footage = noko_elem.at(HOUSING_SEL).text.scan(/\d+/)
			location = /\((.+)\)/.match(noko_elem.at(LOCATION_SEL))
			price = /\d+/.match(noko_elem.at(PRICE_SEL).text)
			summary = noko_elem.at('.//a')

			data['id'] = noko_elem.at('.//a')['data-id']
			data['date'] = Date.parse(noko_elem.at('.//time')['datetime'])
			data['summary'] = summary.text unless summary.nil?
			data['loc'] = location[1] unless location.nil?
			data['coords'] = {'lat' => nil,'lng' => nil}

			data['price'] = price[0].to_i unless price.nil?
			data['beds'] = beds
			data['footage'] = footage
			@listing = data
		end

		def has_coords?
			@listing['coords'] != {"lat"=>nil, "lng"=>nil}
		end

		def value ; @listing ; end

		# some loc data is better than others
		# addresses for instance over city.
		def update_loc
			if @listing['coords'][:lat].nil?
				loc = @listing['loc']
				address = ADDRESS_REGEX.match(loc)
				if address
					coords = get_coords(address[0])
					@listing['coords'] = coords
				end
			end

			if @listing['coords'][:lat].nil?
				summary = @listing['summary']
				address = ADDRESS_REGEX.match(summary)
				baddress = NOT_ADDRESS_REGEX.match(summary)
				if address && !baddress
					coords = get_coords(address[0])
					@listing['coords'] = coords
				end
			end

			# inside a listing, 
			# <div id="map"
			# <div class="mapaddress">1880 Plaza del Sur</div>
			# I should be able to further refine.
			# http://santafe.craigslist.org/apa/5180181123.html

			@listing
		end

		def get_coords(address)
			result = Geocoder.search("#{address[0]} santa fe, new mexico")

			# likely want to put a rescue when the api fails
			# something like {'lat' => nil,'lng' => nil}
			# or don't replace what was there or something.
			coords = result[0].data['geometry']['location']
		end

	end
