# !/usr/bin/env ruby
# module Ruby
# 	class Categoria

	require 'byebug'
	require 'csv'
	require 'mechanize'
	require 'nokogiri'
	require 'open-uri'
	require 'date'
	require 'net/smtp' # for emailing
	
		NOW = Date.today.freeze
		DATA_KEYS = [:expiration,:next_due]
		DATA_HEADERS = %w(expiration next_due).freeze
		DESKTOP_PATH = File.expand_path('./.././../src/categoria', __FILE__).freeze
		def str_to_date(date_str) ; Date.strptime(date_str, '%m/%d/%Y') ; end
		
		## CSVs
		def hash_to_csv(file_name, key_values, headers)
			file = "#{DESKTOP_PATH}/#{file_name}.csv" # :: String x [Hash] x [String] -> [Hash]
		  CSV.open(file, 'w'){|csv| csv << headers.map(&:upcase) } # comment out to queue
			CSV.open(file, 'a') { |csv| csv << key_values.map{|book| book.values.first} }
			read_csv(file_name,key_values.map(&:keys).flatten)
		end
		
		def read_csv(file_name, keys)# :: String x [Symbol] -> [Hash]
			csv = CSV.read("#{DESKTOP_PATH}/#{file_name}.csv")
			csv.last.zip(keys).inject([]){|ary,kv| ary << {kv[1] => kv[0]} }
		end # 1/1/1900, 6/9/2015
		
		data_cache = read_csv('lemon_grass', DATA_KEYS)
		next_cache = hash_to_csv('lemon_grass', data_cache, DATA_HEADERS)
		
		def id(object) ; object ; end # :: a -> a
		def to_f(obj,sym); 	obj.send(sym);end# :: a x Method(Symbol) -> ( a -> b ) 
		
		def trigs(theta)#:: Theta -> Pair[Real]
		  @cos,@sin = %w(sin cos).map{|s| Math.send(s,theta)}
		end
		
		def composition_1(obj,meths={})# :: a x StrAry(a -> b) -> b
			meths.split(' ').map{|f| eval("#{f}(#{obj})")}
		end

		def composition_2(obj,meths={})# :: a x StrAry(a -> b) -> b
			meths.split(' ').inject(obj){|it,f| obj = eval("#{f}(#{it})")}
		end

		def composition_3(obj,meths=:nil)# :: a x [SYMBOLS] -> b
			meths.inject(obj){|obj,sym| obj = obj.send(sym)}
		end

		#  composition_4(data_cache,['id',:first,:keys,:to_s])
		def composition_4(obj,meths=[])
			meths.inject(obj) do |it,f|
				f.is_a?(String) ? obj = eval("#{f}(#{it})") :
			  f.is_a?(Symbol) ? obj = obj.send(f) : obj
			end
		end

		def process
			data_cache = read_csv('lemon_grass', DATA_KEYS)
			next_cache = hash_to_csv('lemon_grass', data_cache, DATA_HEADERS)
		
			one = composition_1(data_cache,'id id id')
			two = composition_2(data_cache,'id id id')
			three = composition_3(data_cache,[:first,:keys,:to_s])
			four = composition_4(data_cache,['id',:first,:keys,:to_s])
			byebug
			# to_f()
		
		end	
		
		process ; byebug ; NOW
# 	end
# end