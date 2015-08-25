class Email
	# a source directory off of crude. --untracked.
	FILES_PATH = File.expand_path('./../../src/meem_library', __FILE__).freeze
	
	
	# nothing here is made to work as
	# of yet. just stub right now.

	def email_builder
		file = File.open(FILES_PATH+'/library_notification_template.txt')
		message = '' ; file.each { |line| message << line }
	
		cache_data = read_csv('data_cache.csv', DATA_KEYS).values.flatten
		date_info = "\nexpiration: %s    next_due: %s\n" % (cache_data[0..1])
	
		books = read_csv('items_out.csv', BOOK_HEADERS)
		book_data = BOOKDATA_SEL.map{|k|books[k]}.transpose.map(&:flatten)
	 	book_info = book_data.inject(''){|s,b| s += ("\n'%s' '%s' %s %s"  % b) }
	
		content = "%s%s%s" % [RENEW_TEXT % @renew_msg, @exp_msg, date_info]
		books_out = BOOKINFO_INIT + book_info + "\n\n"
	
		message = message % (content + books_out)
	
		[:email1,:email2].each do |email_key| 
			%x(echo "#{message}" | mail -s 'meem_notifier' #{INITS_HASH[email_key]})
		end
	end

end