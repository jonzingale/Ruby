	# A testing ground for heat maps antics.

	require 'byebug'

	DateNow = DateTime.now.strftime('%B %d, %Y').freeze
	StartTime = Time.now.strftime('%l:%M %P').freeze

	LAT_LON_REGEX = /lat=-?(\d+\.\d+)&lon=-?(\d+\.\d+)/.freeze
	CURRENT_TEMP_SEL = './/p[@class="myforecast-current-lrg"]'.freeze
	CURRENT_CONDS_SEL = './/div[@id="current_conditions_detail"]/table/tr'.freeze

	USA_MAP = "/Users/Jon/Desktop/us_maps/us_topographic.jpg".freeze # 1152 × 718
	USA_MAP_TEMP = '/Users/Jon/Desktop/us_maps/us_topographic_tmp.jpg'.freeze
	SECONDS = 800.freeze
	DataPt = 9.freeze

	CITY_DATA = [['helena','59601',[455,177]],
							 ['santa fe','87505', [441, 372]],
							 ['bullhead city','86429', [302, 374]],
							 ['cleveland','44107', [1041, 251]],
							 ['monroe','98272', [355, 130]],
							 ['quakertown','18951', [1147, 230]],
							 ['detroit','48201',[1000,253]],
							 ['phoenix','85001',[327,420]],
							 ['atlanta','30301',[1065,435]]
							]

	# probably want to move this into its own world. testing would be easier.
	class Place
		require 'mechanize'
		attr_reader :name, :zipcode, :coords, :geocoords, :agent
		attr_accessor :temp, :humidity, :page, :pressure, :dewpoint

		def initialize name, zipcode, coords
			@name, @zipcode, @coords = name, zipcode, coords

			@agent = Mechanize.new
			agent.follow_meta_refresh = true # new data
			agent.keep_alive = false # no time outs
			# @page = agent.get('http://www.weather.gov')
			scrape_data

			@geocoords = LAT_LON_REGEX.match(page.uri.to_s)[1..2]
		end

		def scrape_data
			@page = agent.get('http://www.weather.gov')
			form = page.form('getForecast')
			form.inputstring = self.zipcode
			@page = form.submit
byebug
			@temp = page.at(CURRENT_TEMP_SEL).text.to_i

			page.search(CURRENT_CONDS_SEL).each do |tr|
				/humidity/i =~ tr.text ?  @humidity = data_grabber(tr,/(\d+)%/i) :
				/barometer/i =~ tr.text ? @pressure = data_grabber(tr,/(\d+\.\d+)/i) :
				/dewpoint/i =~ tr.text ?  @dewpoint = data_grabber(tr,/(\d+)°F/i): nil
			end
		end

		def data_grabber tr, regex
			regex.match(tr.text)
			$1.nil? ? 0 : $1
		end

	end

	cities = CITY_DATA.map{|data| Place.new(*data) }
	cleveland = cities.detect{|i| i.name == 'cleveland'}

	helena = cities.first



byebug ; 4

