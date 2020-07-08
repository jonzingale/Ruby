# !/usr/bin/env ruby
require (File.expand_path('./office_listing', File.dirname(__FILE__)))
require (File.expand_path('./office_region', File.dirname(__FILE__)))
require 'mechanize'
require 'nokogiri'
require 'date'
require 'byebug'

NOW = Date.today.freeze
OFFICE_URL = 'https://santafe.craigslist.org/d/office-commercial/search/off'
BASE_URL = 'http://santafe.craigslist.org'.freeze
HOOD_SEL = './/span[@class="result-hood"]'.freeze
LISTING_STUB = 'http://santafe.craigslist.org/off/%s.html'.freeze
LISTINGS_SEL = './/div[@class="content"]//li[@class="result-row"]'.freeze
NUM_LISTINGS_SEL = './/span[@class="totalcount"]'.freeze
NEXT_BUTTON_SEL = './/a[@title="next page"]'.freeze
BODY_SEL = './/section[@id="postingbody"]'.freeze
COORDS_SEL = './/div[@id="map"]'.freeze

SANTAFE_REGEX = /santafe\.craigslist/
BLACKLIST_LOC = /Arroyo Seco|La Cienega|roswell|embudo|Siringo|Zafarano|Carson New Mexico|Fort Wingate|south ?side|Rodeo|Berino|Mentmore|El Potrero|Rancho Viejo|el Prado|Cuba|Mora|Condo|CR \d+|La Mesilla|Sombrillo|Alcalde|Whites City|Calle Cuesta|San Mateo|Airport|Cerrillos|Sol y Lomas|Ojo Caliente|mobile home|newcomb|Ute Park|Llano Quemado|roswell|Arroyo Hondo|Espanola|Pojoaque|Velarde|Albuquerque|Las Vegas|artesia|Chama|Nambe|AIRPORT|abq|fnm|pub|los alamos|Glorieta|Truchas|Edgewood|Cochiti Lake|cvn|cos|Chimayo|El Prado|El Rancho|Bernalillo|Abiquiu/i
BLIGHTLIST = /boogers/i
BLACK_IDS = /7140589039/
BODY_BLACKLIST = /three days per week|therapy office/i
SQ_BLACKLIST = /sf modified gross/i
BLACKLISTS = [BODY_BLACKLIST, BLIGHTLIST, SQ_BLACKLIST]

def open_listings(listings)
  listings.each do |listing|
    `open "http://santafe.craigslist.org/off/#{listing.value['id']}.html"`
  end
end

def str_to_date(date)
  date_str = date.is_a?(Array) ? date.flatten[0] : date
  Date.strptime(date_str, '%m/%d/%Y')
end

def search(query, agent)
  request_hash = {'max_price' => '500', 
                  'searchNearby' => '0',
                  'query' => query }

  agent.get(OFFICE_URL,request_hash)
end

# true until proven false
def inside?(listing, inside=true)
  if listing.has_coords?
    coords = listing.value['coords'].values
    place = Region.new(*coords)
    inside = place.jordan(5) # within 5 miles only
  end

  inside
end

def process
  agent = Mechanize.new
  page = search('', agent)

  next_button = page.at(NEXT_BUTTON_SEL)
  next_url = next_button.nil? ? nil : BASE_URL+next_button['href']

  num_listings = page.at(NUM_LISTINGS_SEL).text.to_i
  raise 'NoListings' if num_listings < 1

  # cleans listings via location_blacklist on location,
  # keywords_blacklist on summary, and ids
  listings = page.search(LISTINGS_SEL).reject do |ls| 
    hood = ls.at(HOOD_SEL)
    cond1 = BLACKLIST_LOC.match(ls.text)
    cond2 = BLIGHTLIST.match(ls.text)
    cond3 = BLACK_IDS.match(ls.at('.//a')['data-id'])
    cond4 = BLACKLIST_LOC.match(hood.text) unless hood.nil?
    cond5 = !SANTAFE_REGEX.match(ls.at(".//a")['href'])
    cond1 || cond2 || cond3 || cond4 || cond5
  end

  # constructs and array of listings
  listings_data = listings.map{|ls| Listing.new(ls) }

  # get rid of multi-posts
  listings_data.uniq! { |ls| ls.value['summary'] }

  # modify this for better options
  # outside pass at location determining.
  listings_data.select! do |listing|
    listing.update_loc
    inside? listing
  end

  # inside pass at location determining.
  listings_data.select! do |listing|
    page = agent.get(LISTING_STUB % listing.value['id'])
    coords = page.search(COORDS_SEL)

    preCoords = listing.value['coords']
    unless coords.empty? || coords.nil?
      lat = coords.attr('data-latitude').value.to_f
      lng = coords.attr('data-longitude').value.to_f

      listing.update_loc(lat, lng)
    end

    inside? listing
  end

  # body pass at location, filtering.
  listings_data.reject! do |listing|
    page = agent.get(LISTING_STUB % listing.value['id'])
    body = page.search(BODY_SEL).text
    BLACKLISTS.any? { |reg| reg.match(body) }
  end

  # listings_data.each {|ls| puts ls.value['summary'] }
  open_listings(listings_data)
end

process
