# a simple collection of methods
# for getting emails out there.
require 'byebug'
require 'active_support/core_ext/object/blank'

class Email
	# a source directory off of crude. --untracked.
	FILES_PATH = File.expand_path('./..', __FILE__).freeze
	TEMPLATE = File.open(FILES_PATH+'/email_template.txt')
	UNTRACKED = File.open(FILES_PATH+'/untracked.txt')

	ADDRESS_PROMPT = 'to yourself? enter sends to self'.freeze
	ESCAPE = "Press 'q' to quit, anyother to continue".freeze
	HEADER_PROMPT = 'Enter a header here.'.freeze
	MSG_PROMPT = 'Enter a message here.'.freeze

	attr_accessor :address, :message, :header

	def initialize(address='', message='', header='')
		@address = address
		@message = message
		@header = header
	end

	def wait_for_key_press
		begin
		  system("stty raw -echo")
		  str = STDIN.getc
		ensure
		  system("stty -raw echo")
		end ; str
	end

	def from_myself
		key = wait_for_key_press
		if key.ord == 13
			self.address = UNTRACKED.read
		else
			puts 'type email address'
			self.address = gets.chomp
		end
	end

	def send_email
byebug
		unless (self.address || self.message || self.header).blank?
			%x(echo "#{message}" | mail -s '#{header}' #{address} )
		end
	end

	def compose_email
		email = Email.new

		puts ADDRESS_PROMPT
		email.from_myself

		puts HEADER_PROMPT
		email.header = gets.chomp

		puts MSG_PROMPT 
		email.message = gets.chomp

		puts ESCAPE
		key = wait_for_key_press
		email.send_email unless key == 'q' 
	end


	#### the program
	email = Email.new
	email.compose_email
end