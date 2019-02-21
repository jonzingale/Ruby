#!/usr/bin/env ruby
require 'mechanize'
require 'nokogiri'
require 'date'
require 'byebug'

BookingDataUrl = 'https://www.southwest.com/swa-ui/bootstrap/air-booking/11.0.0/data.js'
LandingPage = 'https://www.southwest.com/air/booking/?redirectToVision=trueleapfrogRequest=true'

SearchStub = 'https://www.southwest.com/air/booking/?'

CurrentBookableRegex = /\"currentLastBookableDate\": "(\d+-\d+-\d+)/
FutureBookableRegex = /\"futureBookingCloseDate\": "(\d+-\d+-\d+)/
FutureOpenRegex = /\"futureBookingOpenDate\": "(\d+-\d+-\d+)/
BookingRegexes = [CurrentBookableRegex, FutureBookableRegex, FutureOpenRegex]

# One or less stops
# price: be reasonable < 350 oneway
# time: not super late, not super early

class Itinerary
  attr_accessor :adults, :tripType, :search

  def initialize(dDate, rDate, dAirport='ABQ', oAirport='PIT',
                 adults=1, tripType='roundtrip')
    @dDate, @rDate = dDate, rDate
    @dAirport, @oAirport = dAirport, oAirport
    @adults = adults
    @tripType = tripType
    @search = buildSearch
  end

  def buildSearch
    dd = "departureDate=#{@dDate}&"
    rd = "returnDate=#{@rDate}&"
    da = "destinationAirportCode=#{@dAirport}&"
    oa = "originationAirportCode=#{@oAirport}&"
    aa = "adultPassengersCount=#{@adults}&"
    tt = "tripType=#{@tripType}"
    SearchStub + dd + rd + da + oa + aa + tt
  end

  def writeBookableDates
    agent = Mechanize.new
    page = agent.get(BookingDataUrl)

    bookable = BookingRegexes.map {|r| page.body.match(r)[1]}

    f = File.new("bookable.txt", "w")
    msg1 = "Presently you can book flights through #{bookable[0]}.\n"
    msg2 = "On #{bookable[2]} you can book flights through #{bookable[1]}.\n"
    f.write(msg1+msg2)
  end

  def myItinerary
    print "Michael is leaving #{@oAirport} and arriving at #{@dAirport}"
  end
end

trip = Itinerary.new('2019-09-23', '2019-09-25')
trip.writeBookableDates
# byebug ; 3