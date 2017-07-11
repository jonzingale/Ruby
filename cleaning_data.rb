require 'byebug'
require 'csv'
# cleaning library data for neural net.

FILENAME = './../../books_book_view.csv'

title_words = []
CSV.foreach(FILENAME) do |row|
  title_words += row[1].split
end

clean_words = []
title_words.each do |word|
  word.gsub!(/\W/,'')
  word.downcase!
  clean_words << word if word.length > 2
end

clean_words.shift
clean_words.uniq!

lccn = []
CSV.foreach('./../../books_book_view.csv') do |row|
  if (mt = /^(\D+)\d+/.match(row[3]))
    lccn << mt[1]
  end
end

lccn.shift # removes header
lccn.uniq! # removes duplicates

puts "words:\n#{clean_words.to_s}\n\nlccn_section:\n#{lccn.to_s}"

byebug
