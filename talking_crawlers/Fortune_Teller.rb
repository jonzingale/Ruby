#!/usr/bin/env ruby
# require 'byebug'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'date'

BASE_URL = 'http://forecast.weather.gov/MapClick.php?'.freeze
LOCATION = 'lat=35.652188517187426&lon=-105.94551733055965&site=all&smap=1'.freeze
WEATHER_SEL = './/li[@class="row-odd" or @class="row-even"]'.freeze
JOKES_PAGE = 'http://www.ducksters.com/jokesforkids/silly.php'.freeze

names = ["Agnes","Kathy","Princess","Vicki","Victoria ","Alex",
				 "Bruce","Fred","Junior","Ralph","Albert","Bad News",
				 "Bahh","Bells","Boing","Bubbles","Cellos","Deranged ",
				 "Good News","Hysterical ","Pipe Organ ","Trinoids ",
				 "Whisper ","Zarvox"]

###WEATHER PREDICTION:
day_after = Date.today.next_day.strftime('%A')
weather_service = Nokogiri::HTML(open(BASE_URL+LOCATION))
text = weather_service.search(WEATHER_SEL).map{|t| t.inner_text.gsub('mph','miles per hour')}
text.map{|t| Regexp.new(day_after).match(t) ? %x(say -v Alex #{t})  : nil }
%x(say -v Cellos "the time now is, #{Time.now.strftime('%-I %M, %p')}")

###JOKE SECTION:
joke_page = Nokogiri::HTML(open(JOKES_PAGE))
joke_ary = joke_page.at('body').inner_text.scan(/Q:(.*)|A:(.*)/).map(&:compact)
jokes = (0..(joke_ary.count / 2)-1).inject([]) do |q_a,i|
	qst_ans = joke_ary[2*i] + joke_ary[2*i+1]
	q_a << qst_ans.map do |qa|
		encode1 = qa.encode("iso-8859-1")
		encode2 = encode1.force_encoding("utf-8")
		cleaned = encode2.gsub(/!|\-|\'|'|\"/,'')
	end
end

sleep(3)
%x(say -v Alex 'Do you want to hear a joke?')

(1..2).map do |i| # Tells two jokes
	random_sel = Random.rand(1..(jokes.count)-1)
  %x(sleep 2 ; say -v Alex #{jokes[random_sel][0]} ; 
  	 sleep 2 ; say -v Alex #{jokes[random_sel][1]} ;
  	 sleep 4
  	 )
end


##### Wu Tang:
agent = Mechanize.new
page = agent.get('http://www.mess.be/inickgenwuname.php')
form = page.forms.first

%x(say -v Alex "please, type in your name")
puts "\n\nenter your name"
name = gets.chomp

form['realname'] = name
page = form.submit
wu_text = page.search('.//center').take(2)
msg = wu_text.inject(""){|out,c| out+c.inner_text+','}
clean_msg = msg.gsub("\n",'').split(' from').join('. From')

%x(say -v Alex #{clean_msg})

# byebug ; '5'


