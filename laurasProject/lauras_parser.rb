require 'csv'

REGEX = /or resident/i
TEXT_FILE = 'postcards.txt'
CSV_FILE = 'postcards.csv'

text = File.open(TEXT_FILE,'r').read.gsub("\r", '').split("\n")

idxs = []
text.each_with_index { |l, i| idxs << i - 1 if REGEX.match(l) }

data = []
idxs.each do |i|
  fullname = text[i]

  if /PO Box/i.match(text[i+2])
    address, street = [text[i+2], nil]
  else
    address, street = text[i+2].split(/ /, 2)
  end

  city, state, zip = text[i+3].split(/ /, 3)
  data << [fullname, address, street, city, state, zip]
end

CSV.open(CSV_FILE, 'w') do |csv|
  data.each { |row| csv << row }
end
