string = "This is totally awesome we are going to get some coffee right now."

def taken_str(paired, accum=0)
  paired.take_while { |i,s| (accum+=i) < 10 }
end

def process string
  sized_words = string.split.map { |s| [s.size, s] }
  accum = []
  until sized_words.empty?
    head = taken_str(sized_words)
    accum << head.map(&:last).join(' ')
    sized_words = sized_words - head
  end
  accum
end

puts process(string)