  require 'geocoder' # https://github.com/alexreisner/geocoder
  coder_keys = [
    "latitude", "longitude", "coordinates", "address", "city", "state",
    "state_code", "postal_code", "country", "country_code"
  ]

  class Listing
    PRICE_SEL = './/span[@class="price" or @class="result-price"]'.freeze
    LOCATION_SEL = './/span[@class="result-hood"]'.freeze
    HOUSING_SEL = './/span[@class="housing"]'.freeze
    ADDRESS_REGEX = /\d{3,} (\w+| )+/.freeze
    NOT_ADDRESS_REGEX = /(SQ|FT)/i.freeze

    def initialize(elem)
      data = Hash.new
      footage_elem = elem.at(HOUSING_SEL)
      location = /\w+ ?\w*/.match(elem.at(LOCATION_SEL))
      price = /\d+/.match(elem.at(PRICE_SEL).text)
      summary = elem.at('.//a[@class="result-title hdrlnk"]')
      data['id'] = elem.search('.//a[@data-id]')[0]['data-id']
      data['date'] = Date.parse(elem.at('.//time')['datetime'])
      data['summary'] = summary.text if summary
      data['loc'] = location[0] if location
      data['coords'] = {'lat' => nil,'lng' => nil}
      data['price'] = price[0].to_i if price
      data['footage'] = footage_elem.text.scan(/\d+/)[0] if footage_elem
      @listing = data
    end

    def has_coords?
      @listing['coords'] != {"lat"=>nil, "lng"=>nil}
    end

    # inspect the listing
    def value
      @listing
    end

    # some loc data is better than others
    # addresses for instance over city.
    def update_loc(lat=nil,lng=nil)
      # getting loc from listing_loc
      if @listing['coords'][:lat].nil?
        loc = @listing['loc']
        address = ADDRESS_REGEX.match(loc)
        get_coords(address[0]) if address
      end

      # getting loc from summary
      if @listing['coords'][:lat].nil?
        summary = @listing['summary']
        address = ADDRESS_REGEX.match(summary)
        baddress = NOT_ADDRESS_REGEX.match(summary)

        get_coords(address) if (address && !baddress)
      end

      # sets coords manually.
      if @listing['coords'][:lat].nil? && lat
        @listing['coords'] = {"lat"=>lat, "lng"=>lng}
      end

      @listing
    end

    def get_coords(address)
      begin
        result = Geocoder.search("#{address} santa fe, new mexico")
        sleep(0.1)
      rescue
        print "Google Geocoding API error: request denied."
      else
        lat, lng = result[0].coordinates
        @listing['coords'] = {"lat"=>lat, "lng"=>lng}
      end
    end

  end
