require 'byebug'
require 'csv'

	FILES_PATH = File.expand_path('./../../../../Downloads', __FILE__)
	FILE1 = "#{FILES_PATH}/export_jon.csv"

	INDICES = (0...10).to_a
	METHODS = [:credit_total, :debit_total, :date_span, :per_hour, :per_month,
						 :per_year, :dates, :credit, :debit, :description]

	DATA = INDICES.zip(METHODS).inject({}){|hash,(a,b)| hash.merge(a => b) }

	CONTENTS = <<-FOO
		\n\n
		0* credit total over csv
		1* debit total over csv
		2* date span considered
		3* per hour wage
		4* per month wage
		5* per year wage
		6* dates list
		7* credit list
		8* debit list
		9* description list
		q to quit
	FOO

	def wait_for_key_press
		begin
		  system("stty raw -echo")
		  str = STDIN.getc
		ensure
		  system("stty -raw echo")
		end ; str
	end

	class Bank
		attr_accessor :dates, :description, :change, :contents_loop,
									:balance, :credit, :debit

		def initialize
			ary = CSV.open(FILE1,'r').read
			@dates, @description, @change, @balance = ary.transpose
			@debit, @credit = change.partition{|del| /-\$/.match(del)}
		end

		def to_date(date_str)
			month, day, year = date_str.scan(/\d+/)
			Date.parse("#{year}/#{month}/#{day}")
		end

		def date_span
			start = to_date dates.last
			stop = to_date dates.first
			(stop-start).to_f
		end

		def credit_total
			credits = credit.map{|up| /\d+\.\d+/.match(up)[0]}
			credits.map(&:to_f).inject(:+).round(2)
		end

		def debit_total
			debits = debit.map{|dn| /\d+\.\d+/.match(dn)[0]}
			debits.map(&:to_f).inject(:+).round(2)
		end

		def per_hour ; (credit_total / date_span).round(2) ; end
		def per_month ; (per_hour * 30).round(2) ; end
		def per_year ; (per_month * 12).round(2) ; end
	
		def contents_loop
			key = wait_for_key_press
	
			if key == 'q'
				puts 'exiting'
			elsif INDICES.any?{|i| i == key.to_i}
				puts DATA[key.to_i]
				puts self.send(DATA[key.to_i])
				puts 'press key to continue'
	
				wait_for_key_press
				system('clear')
				puts CONTENTS
	
				contents_loop
			else
				contents_loop
			end
		end

	end

	def process
		system('clear')
		bank = Bank.new
		puts CONTENTS
		bank.contents_loop
	end

process

