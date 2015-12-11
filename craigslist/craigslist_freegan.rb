# !/usr/bin/env ruby
require (File.expand_path('./craigslist_geocoder', File.dirname(__FILE__)))
GEMS = %w(byebug csv date nokogiri mechanize open-uri active_support net/smtp)
GEMS.each{|gemm| eval("require '#{ gemm }'") }

	class CraigslistFreegan
		DUE_WINDOW = 5.freeze
		NOW = Date.today.freeze
		# what are the various stubs? santafe . .. 
		# parse santafe or all of craigslist?
		BASE_URL = 'http://santafe.craigslist.org'.freeze
		FREE_URL = 'http://santafe.craigslist.org/search/zip'.freeze
		LISTING_STUB = 'http://santafe.craigslist.org/zip/%s.html'.freeze
		LISTINGS_SEL = './/div[@class="content"]/p[@class="row"]/span'.freeze
		NUM_LISTINGS_SEL = './/span[@class="totalcount"]'.freeze
		NO_RESULTS_SEL = './/div[@class="noresults"]'.freeze
		CONTENT_SEL = './/section[@id="postingbody"]'.freeze
		NEXT_BUTTON_SEL = './/a[@title="next page"]'.freeze
		LOCATION_SEL = './/span[@class="pnr"]/small'.freeze
		GEOCOORDS = %w(latitude longitude).freeze
		MY_HOUSE = [35.680067,-105.962163].freeze
		COORDS_SEL = './/div[@id="map"]'.freeze

		PROBE_REGEX = /curb alert|stuff|take/i.freeze ; PROBE_NEAR = 2 # in miles
	
		# perhaps a csv would be better?
		DESIREABLES = [['computer',5],['house',100],['bass',2],['amplifier',2],
									 ['fender amp',5],['math',15],['bike',20],['lap ?top',15],
									 ['bike',20],['sewing machine',100],['massage chair',100],
									 ['couch',0]].freeze

		def content_regex
			desires = DESIREABLES.transpose[0]
			desire_str = desires.inject('house'){ |str,s| str = str + '|' + s }
			Regexp.new(desire_str,'i')
		end

		def desired_pairs
			desires, distances = DESIREABLES.transpose
			[desires.map { |desire| Regexp.new(desire,'i') }, distances]
		end
		
		def email_builder(listings)
			message = ''
			listings.each do |line|
				summary = line['summary']
				url = LISTING_STUB % line['id']
				msg = "#{summary}  #{url}\n"
			  message << msg
			end

			emails = File.read('./email.txt').split(' ')
			emails.each do |email|
				%x(echo '#{message}' | mail -s 'Free stuff!' #{email})
			end
		end
	
		def todays_posts(page,accum_list=[])
			agent = Mechanize.new # must i Mechanize.new?
			next_button = page.at(NEXT_BUTTON_SEL)
			next_url = next_button.nil? ? nil : BASE_URL+next_button['href']

			start_span = page.at('.//span[@class="rangeTo"]').text.to_i
			end_span = start_span = page.at('.//span[@class="totalcount"]').text.to_i

			listings = page.search(LISTINGS_SEL)

			todays = listings.select do |listing|
				date_str = listing.at('.//time')['datetime']
				Date.parse(date_str) == NOW
			end

			# exclude colorado_springs and albuquerque.
			accum_list += todays.select{|ls| /^\/zip/.match(ls.at('.//@href'))}

			cond = start_span == end_span or todays.empty?
			cond ? accum_list : todays_posts(agent.get(next_url), accum_list)
		end

		def crawl_listing(id)
			agent = Mechanize.new ; page = agent.get(LISTING_STUB % id)

			lat, long = GEOCOORDS.map do |l|
				coords = page.at(COORDS_SEL)
				coords.nil? ? nil : coords["data-#{l}"].to_f
			end

			unless lat.nil?
				is_close = CraigslistGeocoder.jacobi([lat,long],PROBE_NEAR)
			end

			content = page.at(CONTENT_SEL).text
			good_content = content_regex.match(content)

			dist = DESIREABLES.detect{good_content[0]}[1] if good_content

			(is_close||dist) && good_content
		end

		def process
			agent = Mechanize.new ; page = agent.get(FREE_URL)

			# better would be to open a file and check
			# a last scraped date.
			unless (listings = todays_posts(page)).empty?

				listings_data = listings.map do |ls| ; data = Hash.new
					location = /\((.+)\)/.match(ls.at(LOCATION_SEL))
					data['summary'] = ls.at('.//a').text
					data['loc'] = location[1] unless location.nil?
					data['id'] = ls.at('.//a')['data-id']
					data
				end
	
				good_listings = listings_data.select do |data|
					interest = crawl_listing(data['id']) if PROBE_REGEX =~ data['summary']
					is_desired = content_regex.match(data['summary'])
					interest || is_desired
				end
	
				# email
				email_builder(good_listings) unless good_listings.empty?
			end
		end


