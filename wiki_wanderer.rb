#!/usr/bin/env ruby
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'date'
require 'uri'

  TOPICAL_GLUE =['but in other news','meanwhile']
  CLEAN_REGEX = /\/wiki\/(\w+|_)+/.freeze
  BADLINKS = %w(foo).map{|b|"/wiki/#{b}"}.freeze
  WIKI_REGEX = /https?:\/\/en.wikipedia.org\/wiki\//.freeze
  BAD_HREF_REGEX = /Special|Wikipedia|Wikisource|'|\:|File:Lock|\(/.freeze#\%|%
  BADREGEX = /may refer to|have an article|page lists articles/.freeze
  WANDERER_PATH = '/Users/Jon/Desktop/wiki_wanderer.txt'.freeze
  SOUND_PATH = '/Users/Jon/Desktop/wiki_wanderer.aiff'.freeze
  SPAN_SEL = './/span[@class="mw-headline"]'.freeze
  FOLLOWING_PS = './../following-sibling::p'.freeze
  EN_WIKI = 'http://en.wikipedia.org'.freeze
  BAD_TEXT = ["citation required"].freeze

  def condition(next_link,current_page)
    BADLINKS.any?{|b| b == next_link} || 
              BADREGEX.match(current_page.body) || 
                     BAD_HREF_REGEX.match(next_link)
  end

  def back_up(links)
    it = links[Random.rand(links.count)]
    agent.get(EN_WIKI+it)
  end

  wiki = '' ; puts "\n\nenter a start string" ; name = gets.chomp

  agent = Mechanize.new
  google_page = agent.get('http://www.google.com')
  google_form = google_page.form_with(name: 'f')
  google_form.q = "#{name} wikipedia"
  google_page = agent.submit(google_form) 

  google_page_body = google_page.search('.//a/@href')
  wiki_select = google_page_body.detect{|href| WIKI_REGEX.match(href)}
  wiki_page = /(https?:\/\/en.+)\&sa/.match(wiki_select)[1] # replace sa with .+ ?
  old_link =/\/wiki\/.+/. match(URI.unescape(wiki_page))[0]
  agent.get(URI.unescape(wiki_page))

  list_of_links = [old_link]
  current_page = agent.get(next_link = EN_WIKI+old_link)

  (1..15).map do |i| # 27 largest so far
    spans_contents = current_page.search(SPAN_SEL)
    contents = spans_contents.map{|s| s.at(FOLLOWING_PS)}.compact

    while contents.count < 3
      back_up(list_of_links)
      spans_contents = current_page.search(SPAN_SEL)
      contents = spans_contents.map{|s| s.at(FOLLOWING_PS)}.compact
    end

    good_links = contents.inject([]) do |links,con|
      hrefs = con.search('.//a/@href')
      nice_links = hrefs.select{|h| /^\/wiki\//.match(h)}
      links + nice_links
    end

    while (content = contents.shuffle.first).blank?
      content = contents.shuffle.first
    end
    
    while (next_link = good_links.shuffle.first).blank?
      next_link = good_links.shuffle.first
    end ; @next_link = next_link.value

    list_of_links = [@next_link]+list_of_links

    while condition(@next_link,current_page) == true
      if contents.count < 3 || condition(@next_link,current_page) == true
        next_link = list_of_links.shift
        agent.get(EN_WIKI+next_link)
      end
      @next_link = good_links.shuffle.first.value
      [@next_link]+list_of_links
    end
            # perhaps if the next topic is relevant use 'meanwhile'
    wiki << "#{content.inner_text}. #{TOPICAL_GLUE[Random.rand(TOPICAL_GLUE.count)]}."

    puts next_link
    agent.get(EN_WIKI+next_link)
  end

  wiki = wiki.delete('\\"')
  regex_num = BAD_TEXT+wiki.scan(/\[\d+\]/)
  wiki = regex_num.inject(wiki){|str,t|str.gsub(t,"") }
  %x(say -v Alex "#{wiki}" )

