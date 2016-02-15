#!/usr/bin/env ruby
require 'io/console'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'date'
require 'uri'

INTEREST_MSG = "Spacebar, continues.\nThe letter N," \
								"proceeds to a related topic.\nThe " \
								"letter Q quits the program.".freeze

DATES_REGEX = /\((\d+)-(\d+)\)/.freeze
SEARCH_URL = 'search/searcher.py'.freeze
BASE_URL = 'http://plato.stanford.edu/'.freeze
RESULT_URL = './/div[@class="result_url"]/a'.freeze
START_STRING = "\n\nEnter a topic to investigate.".freeze
RELATED_ENTRIES = 'div[@id="related-entries"]//a/@href'.freeze
PREAMBLE_SEL = './/div[@id="aueditable"]/div[@id="preamble"]'.freeze
MAIN_TEXTS_SEL = './/div[@id="main-text"]'.freeze
BAD_REGEXES = [/\(\d+\.\d+\)/,/\(*( *\w+ \d+\w*,*\)*)+/].freeze

def text_cleaner(texts)# ::[string]->string
	texts.inject('') do |msg,str|
		escapeless = str.delete('\\"')
		bad_regex = BAD_REGEXES+escapeless.scan(/\[\d+\]/)
		clean = bad_regex.inject(escapeless){|str,t|str.gsub(t,"") }
		unless (dates = DATES_REGEX.match(clean)).nil?
			clean = clean.gsub(/\(\d+-\d+\)/,"from #{dates[1]} to #{dates[2]}")
		end
		msg << clean
	end
end

def reads_preamble(page)# ::Page -> IO()
	preamble = text_cleaner([page.at(PREAMBLE_SEL).inner_text])
	%x(say -v Alex "#{preamble}")
	system 'clear' ; puts INTEREST_MSG
	sleep(1) ; %x(say -v Alex "#{INTEREST_MSG}")
end

def getch# ::IO() -> Char
  %x[stty -echo raw]
  @c = $stdin.getc
  %x[stty echo -raw]
end

puts START_STRING ; name = gets.chomp
agent = Mechanize.new
page = agent.get(BASE_URL)
form = page.form_with(action: SEARCH_URL)
form.query = form.field_with(name: "query").value = "#{name}"
page = agent.submit(form)

current_page = agent.get(page.at(RESULT_URL).inner_text)

# gets a good start page.
while !(t_page = current_page.at(RESULT_URL)).nil?
	current_page = agent.get(t_page.inner_text)
end ; puts t_page

@c = '' ; while @c!='q'
	if @c == ''
		system 'clear'
		reads_preamble(current_page)
		while %w(\  n q).map{|t| @c != t}.all?
			getch
		end

	elsif @c == ' '
		main_texts = current_page.search(MAIN_TEXTS_SEL).map(&:inner_text)
		msg = text_cleaner(main_texts)
		%x(say -v Alex "#{msg}")
		@c = 'n'

	elsif @c == 'n'
		links = current_page.search(RELATED_ENTRIES)
		clean_links = links.map{|l| "#{BASE_URL}/entries#{/\.\.(.+)/.match(l.inner_text)[1]}"}
		rand_link = clean_links[Random.rand(clean_links.count)]
		current_page = agent.get(rand_link)		
		@c = ''
	end
end
