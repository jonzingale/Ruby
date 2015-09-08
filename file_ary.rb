	# treat files like arrays.
	require 'byebug'
	FILES_PATH = File.expand_path('./../data', __FILE__)
	EXAMPLE = "#{FILES_PATH}/color_distributions.csv"
	FILE1 = "#{FILES_PATH}/file1.csv"
	FILE2 = "#{FILES_PATH}/file2.csv"
	TEMP = "#{FILES_PATH}/tmp.csv"
	TEMP2 = "#{FILES_PATH}/tmp2.csv"

	# TODO: DATA
	# will want the first file to not already have counts.

	class FileAry
		# keep things as strings.
		attr_accessor :read, :head, :lines, :path, :count
		def initialize(path)
			@path = path
			@read = File.open(path,'r').read
			@head = read.lines.first
			@lines = read.lines
			@count = lines.count
		end

		# not sure how this works
		# def rename(new_name_path)
		# 	File.rename(self.path, new_name_path)
		# end

		def delete
			File.open(self.path,'w')
			@read = File.open(path,'r').read
			@head = read.lines.first
			@lines = read.lines
			@count = lines.count
		end

		# too slow for each line in chunks?
		# keep file open while accumulating.
		def append(content)
			File.open(path,'a'){|target| target << content}
			new_file = FileAry.new(path)
			@read = new_file.read
			@head = read.lines.first
			@lines = read.lines
		end

		def copy_from(src)
			File.open(self.path,'w'){|file| file << src.read}
			@read = src.read
			@head = read.lines.first
			@lines = read.lines
			@count = lines.count
		end

		def chunked_append
			ary = []
			while ary.count < 1000
				color = head
				count = same_as_first_count
				ary << [color, count]
				delete_same_as
			end ; ary
		end

		def same_as_first_count
			self.lines.count{|i| self.head == i }
		end	

		def delete_same_as(content)
			temp = FileAry.new(TEMP)
			temp.delete

			File.open(temp.path,'a') do |file|
				File.open(self.path,'r').each_line do |line|
					file << line if line != content
				end
			end

			temp = FileAry.new(TEMP)
			self.copy_from(temp)
			@read = temp.read
			@head = read.lines.first
			@lines = read.lines
			@count = lines.count
			temp.delete
		end
	end


	##### outside of class
	def process_color(file_ary,temp2)
		unless file_ary.head.nil?
			# do this in chunks i suspect
			head_count = file_ary.same_as_first_count
			ary_head = file_ary.head

			file_ary.delete_same_as(ary_head)
			file_ary = FileAry.new(file_ary.path)

			# TODO TODO TODO
			# look into truncate and other such
			# methods that might be faster than append
			# it seems I have to use an array at least here.
			# maybe I can write eacy to a file?
			mt_head = /\-\d+/.match(ary_head)[0] #<--- because of stupid format
			temp2.append("#{mt_head},#{head_count}\n")
			process_color(file_ary,temp2)
		end
	end

	def color_counts(file_ary) # that is self
		temp2 = FileAry.new(TEMP2)
		temp2.delete

		process_color(file_ary,temp2)
		temp2 = FileAry.new(TEMP2)
	end

	it = FileAry.new(FILE1)
	that = FileAry.new(FILE2)
	that.copy_from(it)

	color_counts(that)
	

	byebug ; 4
