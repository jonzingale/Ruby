	require 'geocoder'
	# better might be to call this Apartment
	# or HouseListing or Rentals, so that
	# it can be distinguished from listings
	# on craigslist free or something else.

	class Listing
		PRICE_SEL = './/span[@class="price" or @class="result-price"]'.freeze
		LOCATION_SEL = './/span[@class="pnr"]/small'.freeze
		HOUSING_SEL = './/span[@class="housing"]'.freeze
		ADDRESS_REGEX = /\d{3,} (\w+| )+/.freeze
		NOT_ADDRESS_REGEX = /(SQ|FT)/i.freeze

		def initialize(elem)
			data = Hash.new
			beds, footage = elem.at(HOUSING_SEL).text.scan(/\d+/)
			location = /\((.+)\)/.match(elem.at(LOCATION_SEL))
			price = /\d+/.match(elem.at(PRICE_SEL).text)
			summary = elem.at('.//a')
			data['id'] = elem.search('.//a[@data-id]')[0]['data-id']
			data['date'] = Date.parse(elem.at('.//time')['datetime'])
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
		def update_loc(lat=nil,lng=nil)
			# getting loc from listing_loc
			if @listing['coords'][:lat].nil?
				loc = @listing['loc']
				address = ADDRESS_REGEX.match(loc)
				if address
					coords = get_coords(address[0])
					@listing['coords'] = coords
				end
			end

			# getting loc from summary
			if @listing['coords'][:lat].nil?
				summary = @listing['summary']
				address = ADDRESS_REGEX.match(summary)
				baddress = NOT_ADDRESS_REGEX.match(summary)
				if address && !baddress
					coords = get_coords(address[0])
					@listing['coords'] = coords
				end
			end

			# sets coords manually.
			if @listing['coords'][:lat].nil? && lat
				@listing['coords'] = {"lat"=>lat, "lng"=>lng}
			end

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
