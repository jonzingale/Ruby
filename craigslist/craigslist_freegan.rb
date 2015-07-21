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
	class CraigslistFreegan
		DUE_WINDOW = 5.freeze
		NOW = Date.today.freeze
		BASE_URL = 'http://santafe.craigslist.org'.freeze
		FREE_URL = 'http://santafe.craigslist.org/search/zip'.freeze
		LISTING_STUB = 'http://santafe.craigslist.org/zip/%s.html'.freeze
		LISTINGS_SEL = './/div[@class="content"]/p[@class="row"]/span'.freeze
		NUM_LISTINGS_SEL = './/span[@class="totalcount"]'.freeze
		NO_RESULTS_SEL = './/div[@class="noresults"]'.freeze
		NEXT_BUTTON_SEL = './/a[@title="next page"]'.freeze
		LOCATION_SEL = './/span[@class="pnr"]/small'.freeze
		GEOCOORDS = %w(latitude longitude).freeze
		MY_HOUSE = [35.680067,-105.962163].freeze

		# probing_further whitelist, should likely be near:
		# the idea here that we may want to open the link and
		# check the summary.
		PROBE_LIST = /curb alert|stuff|take/i.freeze
		PROBE_NEAR = 2 # in miles
	
		# include number of miles willing to travel for thing.
		DESIREABLES = []
	
		# a source directory off of crude. --untracked.
		FILES_PATH = File.expand_path('./..', __FILE__).freeze
		# records_file = CSV.read("#{FILES_PATH}/craigslist_records.csv") ; 
	
		##########
		keys = [:borrower_id, :email1, :email2]	
	
		def str_to_date(date)
			date_str = date.is_a?(Array) ? date.flatten[0] : date
			Date.strptime(date_str, '%m/%d/%Y')
		end
		
		def email_builder
			file = File.open(FILES_PATH+'/library_notification_template.txt')
			message = '' ; file.each { |line| message << line }
		
			cache_data = read_csv('data_cache.csv', DATA_KEYS).values.flatten
			date_info = "\nexpiration: %s    next_due: %s\n" % (cache_data[0..1])
		
			books = read_csv('items_out.csv', BOOK_HEADERS)
			book_data = BOOKDATA_SEL.map{|k|books[k]}.transpose.map(&:flatten)
		 	book_info = book_data.inject(''){|s,b| s += ("\n'%s' '%s' %s %s"  % b) }
		
			content = "%s%s%s" % [RENEW_TEXT % @renew_msg, @exp_msg, date_info]
			books_out = BOOKINFO_INIT + book_info + "\n\n"
		
			message = message % (content + books_out)
		
			[:email1,:email2].each do |email_key| 
				# %x(echo '#{message}' | mail -s 'meem_notifier' #{INITS_HASH[email_key]})
			end
		end
		
		###############
	
		def self.process
			agent = Mechanize.new
			page = agent.get(FREE_URL)
			next_button = page.at(NEXT_BUTTON_SEL)
			next_url = next_button.nil? ? nil : BASE_URL+next_button['href']
		
			num_listings = page.at(NUM_LISTINGS_SEL).text.to_i
			raise 'NoListings' if num_listings < 1
		
			listings = page.search(LISTINGS_SEL)
	
			# maybe based on distance?
			# good_listings = listings.reject{|ls| BLACKLIST.match(ls.text)}
	
			listings_data = listings.map do |ls| ; data = Hash.new
				location = /\((.+)\)/.match(ls.at(LOCATION_SEL))
				data['summary'] = ls.at('.//a').text
				data['loc'] = location[1] unless location.nil?
				data['date'] = Date.parse(ls.at('.//time')['datetime'])
				data['id'] = ls.at('.//a')['data-id']
				data
			end
	
		# the thing I think that I want here is to create an array of listings
		# which either explicitly state a desireable or possibly do wrt the
		# Probing_Whitelist
	
		# in a listing.
			page = agent.get(LISTING_STUB % listings_data[0]['id'])
			lat, long = GEOCOORDS.map{|l|page.at('.//div[@id="map"]')["data-#{l}"].to_f}
			content = page.at('.//section[@id="postingbody"]').text

			# this doesn't seem right
			is_close = CraigslistGeocoder.jacobi([lat,long],PROBE_NEAR)
			how_far  = CraigslistGeocoder.dist([lat,long],MY_HOUSE)
byebug


			# email
			email_builder
		end
	
		CraigslistFreegan.process
	end
end
# {"summary"=>"FREE Clean MOVING BOXES", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132282033"}
# {"summary"=>"1995 Chevy Astro awd rear seats", "loc"=>"Taos (Arroyo Hondo", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132273425"}
# {"summary"=>"4 inch foam mattress- 5th gen 4Runner", "loc"=>"SANTA FE", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132035561"}
# {"summary"=>"CRT Monitor", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5115227065"}
# {"summary"=>"curb alert", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5131749469"}
# {"summary"=>"Free baby boy clothes", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5131771468"}
# {"summary"=>"2 cats", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5131635033"}
# {"summary"=>"Free moving boxes", "date"=>#<Date: 2015-07-19 ((2457223j,0s,0n),+0s,2299161j)>, "id"=>"5131189205"}
# {"summary"=>"Free Handicap Access Ramps", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-19 ((2457223j,0s,0n),+0s,2299161j)>, "id"=>"5131184375"}
# {"summary"=>"Treadmill", "loc"=>"Mora", "date"=>#<Date: 2015-07-19 ((2457223j,0s,0n),+0s,2299161j)>, "id"=>"5131156034"}
# {"summary"=>"Miscellaneous Organic Skin Care Products", "loc"=>"Pojoaque", "date"=>#<Date: 2015-07-19 ((2457223j,0s,0n),+0s,2299161j)>, "id"=>"5131153814"}
# {"summary"=>"CD/DVD Printer Labels", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-19 ((2457223j,0s,0n),+0s,2299161j)>, "id"=>"5131012174"}
# {"summary"=>"Free Sand and Gravel", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-19 ((2457223j,0s,0n),+0s,2299161j)>, "id"=>"5130888097"}
# {"summary"=>"Carpet Remnant", "loc"=>"Santa fe", "date"=>#<Date: 2015-07-19 ((2457223j,0s,0n),+0s,2299161j)>, "id"=>"5130879064"}
# {"summary"=>"Free gas dryer hookup and 24\" towel bar, chrome", "loc"=>"Las Acequias, Santa FE", "date"=>#<Date: 2015-07-19 ((2457223j,0s,0n),+0s,2299161j)>, "id"=>"5130851474"}
# {"summary"=>"Blankets, pillow cases, comforters, pillows", "loc"=>"Los Alamos", "date"=>#<Date: 2015-07-19 ((2457223j,0s,0n),+0s,2299161j)>, "id"=>"5130701596"}
# {"summary"=>"2000 f350 shocks and speakers", "loc"=>"Los Alamos", "date"=>#<Date: 2015-07-19 ((2457223j,0s,0n),+0s,2299161j)>, "id"=>"5130360663"}
# {"summary"=>"pull golf cart", "loc"=>"pojoaque", "date"=>#<Date: 2015-07-19 ((2457223j,0s,0n),+0s,2299161j)>, "id"=>"5129984270"}
# {"summary"=>"two indoor cats", "loc"=>"taos", "date"=>#<Date: 2015-07-18 ((2457222j,0s,0n),+0s,2299161j)>, "id"=>"5119871125"}
# {"summary"=>"Poly Batting and Pillow Stuffing", "loc"=>"S Santa Fe", "date"=>#<Date: 2015-07-18 ((2457222j,0s,0n),+0s,2299161j)>, "id"=>"5119637251"}
# {"summary"=>"Leaving behind a ton of stuff!!!!", "date"=>#<Date: 2015-07-18 ((2457222j,0s,0n),+0s,2299161j)>, "id"=>"5129552609"}
# {"summary"=>"Antique lawyers desk - needs some lovin'", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-18 ((2457222j,0s,0n),+0s,2299161j)>, "id"=>"5129501701"}
# {"summary"=>"3-ring binder dividers", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-18 ((2457222j,0s,0n),+0s,2299161j)>, "id"=>"5129389489"}
# {"summary"=>"Curb alert", "loc"=>"santa fe", "date"=>#<Date: 2015-07-18 ((2457222j,0s,0n),+0s,2299161j)>, "id"=>"5129318751"}
# {"summary"=>"Free moving boxes and newsprint padding", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-18 ((2457222j,0s,0n),+0s,2299161j)>, "id"=>"5129245338"}
# {"summary"=>"Free Roof structure or wood lumber", "loc"=>"Espanola nm", "date"=>#<Date: 2015-07-18 ((2457222j,0s,0n),+0s,2299161j)>, "id"=>"5100105155"}
# {"summary"=>"FREE CONSOLE TV WORKS PERFECT", "loc"=>"TAOS ARROYO HONDO", "date"=>#<Date: 2015-07-18 ((2457222j,0s,0n),+0s,2299161j)>, "id"=>"5105210176"}
# {"summary"=>"FREE: 21\" CRT monitor, HP laserjet 4m+", "loc"=>"Los Alamos", "date"=>#<Date: 2015-07-17 ((2457221j,0s,0n),+0s,2299161j)>, "id"=>"5128466774"}
# {"summary"=>"Moving Boxes and supplies", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-17 ((2457221j,0s,0n),+0s,2299161j)>, "id"=>"5127794587"}
# {"summary"=>"Lumber, scrap wood, take as much or as little as you like", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-16 ((2457220j,0s,0n),+0s,2299161j)>, "id"=>"5098768095"}
# {"summary"=>"free single sized transformable futon frame", "loc"=>"Santa fe", "date"=>#<Date: 2015-07-14 ((2457218j,0s,0n),+0s,2299161j)>, "id"=>"5123289537"}
# {"summary"=>"Sony TV and video player", "date"=>#<Date: 2015-07-13 ((2457217j,0s,0n),+0s,2299161j)>, "id"=>"5121685214"}
# {"summary"=>"Female Chihuahua", "date"=>#<Date: 2015-07-12 ((2457216j,0s,0n),+0s,2299161j)>, "id"=>"5119958716"}
# {"summary"=>"Christmas dinner chinet", "loc"=>"SantaFe", "date"=>#<Date: 2015-07-11 ((2457215j,0s,0n),+0s,2299161j)>, "id"=>"5108088696"}
# {"summary"=>"Dish Network", "date"=>#<Date: 2015-07-11 ((2457215j,0s,0n),+0s,2299161j)>, "id"=>"5118676960"}
# {"summary"=>"curb alert!! free old TV for parts.", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-11 ((2457215j,0s,0n),+0s,2299161j)>, "id"=>"5118392848"}
# {"summary"=>"Free rocks, sand, soil", "loc"=>"Siringo Road, Santa Fe", "date"=>#<Date: 2015-07-11 ((2457215j,0s,0n),+0s,2299161j)>, "id"=>"5117693326"}
# {"summary"=>"Free 59\" x 28\" Freezer", "loc"=>"Jemez Springs", "date"=>#<Date: 2015-07-11 ((2457215j,0s,0n),+0s,2299161j)>, "id"=>"5117648754"}
# {"summary"=>"Free couch", "date"=>#<Date: 2015-07-10 ((2457214j,0s,0n),+0s,2299161j)>, "id"=>"5116903274"}
# {"summary"=>"Looking for FREE wood shipping pallets", "loc"=>"Espanola", "date"=>#<Date: 2015-07-10 ((2457214j,0s,0n),+0s,2299161j)>, "id"=>"5090982348"}
# {"summary"=>"FREE HORSE MANURE FOR YOUR GARDEN 4 PICKUP or POSSIBLE DELIVERY", "loc"=>"No. Santa Fe/Pojoaque", "date"=>#<Date: 2015-07-09 ((2457213j,0s,0n),+0s,2299161j)>, "id"=>"5069096416"}
# {"summary"=>"RE: Save Big!! This Sunday 7/12", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-09 ((2457213j,0s,0n),+0s,2299161j)>, "id"=>"5114273875"}
# {"summary"=>"Free couch and TV", "date"=>#<Date: 2015-07-08 ((2457212j,0s,0n),+0s,2299161j)>, "id"=>"5112818809"}
# {"summary"=>"RE: \"Free Sinks Bathtub Etc\" Are You Kidding Me?", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-05 ((2457209j,0s,0n),+0s,2299161j)>, "id"=>"5107564498"}
# {"summary"=>"moving boxes, bubble wrap, etc.", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-03 ((2457207j,0s,0n),+0s,2299161j)>, "id"=>"5105660413"}
# {"summary"=>"FREE Sonos Bridge", "date"=>#<Date: 2015-07-03 ((2457207j,0s,0n),+0s,2299161j)>, "id"=>"5105056578"}
# {"summary"=>"love seat recliner and recliner", "loc"=>"Santa Fe", "date"=>#<Date: 2015-07-02 ((2457206j,0s,0n),+0s,2299161j)>, "id"=>"5103292916"}
# {"summary"=>"free", "date"=>#<Date: 2015-07-01 ((2457205j,0s,0n),+0s,2299161j)>, "id"=>"5102792019"}
# {"summary"=>"twin mattress and boxspring, good condition", "loc"=>"Franklin Ave. btw Hickox and Agua Fria", "date"=>#<Date: 2015-07-01 ((2457205j,0s,0n),+0s,2299161j)>, "id"=>"5102710474"}
# {"summary"=>"Free couch", "date"=>#<Date: 2015-07-01 ((2457205j,0s,0n),+0s,2299161j)>, "id"=>"5101970116"}
# {"summary"=>"lots of free stuff! chairs, cds, Christmas tree, tons more", "loc"=>"Los Alamos", "date"=>#<Date: 2015-06-30 ((2457204j,0s,0n),+0s,2299161j)>, "id"=>"5101022808"}
# {"summary"=>"curb alert free lumber etc", "loc"=>"302 Irvine Street", "date"=>#<Date: 2015-06-30 ((2457204j,0s,0n),+0s,2299161j)>, "id"=>"5100769132"}
# {"summary"=>"Vintage sofa for reupholstering", "loc"=>"Santa fe", "date"=>#<Date: 2015-06-30 ((2457204j,0s,0n),+0s,2299161j)>, "id"=>"5100522386"}
# {"summary"=>"Free plywood", "loc"=>"CHUPADERO", "date"=>#<Date: 2015-06-30 ((2457204j,0s,0n),+0s,2299161j)>, "id"=>"5100488195"}
# {"summary"=>"CURB ALERT", "loc"=>"702 Columbia st", "date"=>#<Date: 2015-06-30 ((2457204j,0s,0n),+0s,2299161j)>, "id"=>"5100475253"}
# {"summary"=>"puppies", "date"=>#<Date: 2015-06-29 ((2457203j,0s,0n),+0s,2299161j)>, "id"=>"5099117064"}
# {"summary"=>"FREE MOVING BOXES", "loc"=>"1102 Camino Carlos Rey Unit D", "date"=>#<Date: 2015-06-29 ((2457203j,0s,0n),+0s,2299161j)>, "id"=>"5098030458"}
# {"summary"=>"Used Queen Size Mattress", "loc"=>"Santa Fe", "date"=>#<Date: 2015-06-28 ((2457202j,0s,0n),+0s,2299161j)>, "id"=>"5096690447"}
# {"summary"=>"Free TV not flatscreen", "loc"=>"rodeo/sawmill", "date"=>#<Date: 2015-06-27 ((2457201j,0s,0n),+0s,2299161j)>, "id"=>"5095389914"}
# {"summary"=>"Truck shell", "loc"=>"Santa Fe", "date"=>#<Date: 2015-06-26 ((2457200j,0s,0n),+0s,2299161j)>, "id"=>"5094534436"}
# {"summary"=>"free interior door hardware", "loc"=>"so. capitol SF", "date"=>#<Date: 2015-06-26 ((2457200j,0s,0n),+0s,2299161j)>, "id"=>"5094494069"}
# {"summary"=>"Trim Molding for Wall Cabinet", "loc"=>"Crestone", "date"=>#<Date: 2015-06-26 ((2457200j,0s,0n),+0s,2299161j)>, "id"=>"5094129594"}
# {"summary"=>"Free- working tv with remote, table lamp, pet dishes, furniture & more", "loc"=>"Los Alamos", "date"=>#<Date: 2015-06-26 ((2457200j,0s,0n),+0s,2299161j)>, "id"=>"5093567445"}
# {"summary"=>"brown couch", "date"=>#<Date: 2015-06-26 ((2457200j,0s,0n),+0s,2299161j)>, "id"=>"5093033221"}
# {"summary"=>"Free pieces of wood, dismantled deck", "loc"=>"Cam Carlos Rey", "date"=>#<Date: 2015-06-25 ((2457199j,0s,0n),+0s,2299161j)>, "id"=>"5092563141"}
# {"summary"=>"FREE BOX SPRING", "date"=>#<Date: 2015-06-25 ((2457199j,0s,0n),+0s,2299161j)>, "id"=>"5092400711"}
# {"summary"=>"I Need Styrofoam Peanuts", "loc"=>"Santa Fe", "date"=>#<Date: 2015-06-25 ((2457199j,0s,0n),+0s,2299161j)>, "id"=>"5091495486"}
# {"summary"=>"Free love seat", "loc"=>"Taos/Lower Los Colonias", "date"=>#<Date: 2015-06-25 ((2457199j,0s,0n),+0s,2299161j)>, "id"=>"5091364796"}
# {"summary"=>"Comfy green couch", "loc"=>"Hopi Rd", "date"=>#<Date: 2015-06-24 ((2457198j,0s,0n),+0s,2299161j)>, "id"=>"5090763247"}
# {"summary"=>"FREE! COME TAKE NOW!", "loc"=>"903 Lopez street", "date"=>#<Date: 2015-06-23 ((2457197j,0s,0n),+0s,2299161j)>, "id"=>"5088124182"}
# {"summary"=>"Arborists & dump your mulch", "loc"=>"Santa Fe", "date"=>#<Date: 2015-06-21 ((2457195j,0s,0n),+0s,2299161j)>, "id"=>"5086030754"}
# {"summary"=>"FREE Furniture", "date"=>#<Date: 2015-06-21 ((2457195j,0s,0n),+0s,2299161j)>, "id"=>"5085803021"}
# {"summary"=>"Free Couch / Recliner", "loc"=>"santa fe", "date"=>#<Date: 2015-06-21 ((2457195j,0s,0n),+0s,2299161j)>, "id"=>"5085127097"}
# {"summary"=>"FREE Fashion Magazines", "loc"=>"Santa Fe", "date"=>#<Date: 2015-06-20 ((2457194j,0s,0n),+0s,2299161j)>, "id"=>"5084399219"}
# {"summary"=>"FREE -Please, come take it all!", "loc"=>"903 Lopez st", "date"=>#<Date: 2015-06-20 ((2457194j,0s,0n),+0s,2299161j)>, "id"=>"5084217446"}
# {"summary"=>"FREE MOVING BOXES - LARGE & MEDIUM", "loc"=>"Santa Fe", "date"=>#<Date: 2015-06-20 ((2457194j,0s,0n),+0s,2299161j)>, "id"=>"5083785040"}
# {"summary"=>"Fryer Oil", "loc"=>"Ranchos de Taos", "date"=>#<Date: 2015-06-19 ((2457193j,0s,0n),+0s,2299161j)>, "id"=>"5082601771"}
# {"summary"=>"Wedding Table Centerpieces (8)", "date"=>#<Date: 2015-06-18 ((2457192j,0s,0n),+0s,2299161j)>, "id"=>"5081163213"}
# {"summary"=>"small couch", "loc"=>"santa fe", "date"=>#<Date: 2015-06-16 ((2457190j,0s,0n),+0s,2299161j)>, "id"=>"5078101554"}
# {"summary"=>"Free stereo and speakers", "loc"=>"Los Alamos", "date"=>#<Date: 2015-06-15 ((2457189j,0s,0n),+0s,2299161j)>, "id"=>"5076382581"}
# {"summary"=>"Free Hot Tub", "loc"=>"Santa Fe Southside", "date"=>#<Date: 2015-06-15 ((2457189j,0s,0n),+0s,2299161j)>, "id"=>"5075725316"}
# {"summary"=>"Yard Sale with Free stuff SAT only 9-noon", "loc"=>"1719 Siri Dharma Ct Santa Fe", "date"=>#<Date: 2015-06-13 ((2457187j,0s,0n),+0s,2299161j)>, "id"=>"5072295811"}
# {"summary"=>"free tomato plants in Chili", "loc"=>"next to chevron", "date"=>#<Date: 2015-06-12 ((2457186j,0s,0n),+0s,2299161j)>, "id"=>"5071000029"}
# {"summary"=>"box spring", "date"=>#<Date: 2015-06-07 ((2457181j,0s,0n),+0s,2299161j)>, "id"=>"5062811663"}
# {"summary"=>"Free stuff", "loc"=>"3226 calle de molina", "date"=>#<Date: 2015-06-06 ((2457180j,0s,0n),+0s,2299161j)>, "id"=>"5061456487"}
# {"summary"=>"Free dressers", "date"=>#<Date: 2015-06-06 ((2457180j,0s,0n),+0s,2299161j)>, "id"=>"5061388648"}
# {"summary"=>"FREE WALL PANELS 8'X40'", "loc"=>"Espanola", "date"=>#<Date: 2015-06-06 ((2457180j,0s,0n),+0s,2299161j)>, "id"=>"5061110133"}
# {"summary"=>"free / free / free", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132579767"}
# {"summary"=>"55 inch Flat Screen TV", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132583830"}
# {"summary"=>"Ethan Allen couch/ fold out bed", "loc"=>"abq > Duranes", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132567852"}
# {"summary"=>"Curb alert ..furniture", "loc"=>"abq > Rio rancho", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132542911"}
# {"summary"=>"Rio Rancho", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132524946"}
# {"summary"=>"Curb Alert, Free Trex Decking", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132510842"}
# {"summary"=>"Free Chimineas (2)", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132510066"}
# {"summary"=>"Fisher price smart cycle", "loc"=>"abq > Westside", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132505754"}
# {"summary"=>"Large table", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5128918162"}
# {"summary"=>"curb alert furnati26 sunflower rd", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132464524"}
# {"summary"=>"dressers", "loc"=>"cos > Flintridge and Academy", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132440619"}
# {"summary"=>"Nice tan recliner couch and dresser", "loc"=>"cos > Near Fort Carson", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5132413284"}
# {"summary"=>"Free pre k on Tramway", "loc"=>"abq > Albuquerque", "date"=>#<Date: 2015-07-20 ((2457224j,0s,0n),+0s,2299161j)>, "id"=>"5127900793"}

