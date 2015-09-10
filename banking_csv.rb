require 'csv'
require 'byebug'

	FILES_PATH = File.expand_path('./../../../../Downloads', __FILE__)
	FILE1 = "#{FILES_PATH}/export.csv"

	class Bank
		attr_accessor :date, :number, :description, :debit, :credit
		def initialize
			ary = CSV.open(FILE1,'r').read
			@date, @number, @description, @debit, @credit = ary.transpose
		end

		def to_date(date_str)
			month, day, year = date_str.scan(/\d+/)
			Date.parse("#{year}/#{month}/#{day}")
		end

		def date_span
			start = to_date @date.last
			stop = to_date @date[1]
			(stop-start).to_f
		end

		def credit_total ; @credit.map(&:to_f).inject :+ ; end
		def debit_total ; @debit.map(&:to_f).inject :+ ; end

		def per_hour ; credit_total / date_span ; end
		def per_month ; per_hour * 30 ; end
		def per_year ; per_month * 12 ; end
	end

	bank = Bank.new

byebug ; 4

