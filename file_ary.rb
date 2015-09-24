	# treat files like arrays.
	require 'byebug'
	require 'csv'

	# how do I get these caches cleared?
	# even with some faster ideas, this
	# is likely to be a slow project.
	# chunking will likely mean needing
	# to pass over the same chunks :(x

	FILES_PATH = File.expand_path('./../data', __FILE__)
	# EXAMPLE = "#{FILES_PATH}/color_distributions.csv"
	FILE1 = "#{FILES_PATH}/file1.csv"
	FILE2 = "#{FILES_PATH}/file2.csv"
	TEMP = "#{FILES_PATH}/tmp.csv"
	TEMP2 = "#{FILES_PATH}/tmp2.csv"

	class FileAry
		# attr_accessors are slow.
		attr_accessor :read, :head, :lines, :path, :count
		def initialize(path)
			@path = path
			@read = File.open(path,'r').read
			@head = read.lines.first
			@lines = read.lines
			@count = lines.count
		end

		def delete
			# truncate?
			File.open(self.path,'w')
			@read = File.open(path,'r').read
			@head = read.lines.first
			@lines = read.lines
			@count = lines.count
		end

		# too slow for each line in chunks?
		# keep file open while accumulating.
		# each_slice
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
			CSV.open(TEMP,'w')
			@i = count

			until @i <= 0
				ary = []
				# i feel like this should be faster somehow.
				self.lines.take(1000).map do |line|
					color = line.to_i
					color_count = self.same_as_first_count
					self.delete_same_as(line)
					ary << [color, color_count]
				end ; @i -= 1000

	puts @i
				CSV.open(TEMP,'a'){|csv| ary.each{|a|csv << a}}
			end

			temp = FileAry.new(TEMP)

byebug
			ary
		end

		def same_as_first_count
			self.lines.count{|i| @lines.first == i }
		end	

		def delete_same_as(content)
			# how do I update an object easily?
byebug
			self.read.lines.reject!{|i| i==content}
byebug
		end

# 		# this is a likely bottleneck.
# 		def delete_same_as(content)
# 			temp = FileAry.new(TEMP2)
# 			temp.delete

# 			File.open(temp.path,'a') do |file|
# byebug
# 				File.open(self.path,'r').each_line do |line|
# 					file << line if line != content
# 				end
# 			end

# 			new_file = File.open(temp.path,'r')
# 			@read = new_file.read
# 			@head = read.lines.first
# 			@lines = read.lines
# 			@count = lines.count
# 		end
	end


	##### outside of class
	def process_color(file_ary,temp2)
		unless file_ary.head.nil?
			# do this in chunks i suspect
			head_count = file_ary.same_as_first_count
			ary_head = file_ary.head.to_i

			file_ary.delete_same_as(ary_head)
			file_ary = FileAry.new(file_ary.path)

			# TODO TODO TODO
			# look into truncate and other such
			# methods that might be faster than append
			# it seems I have to use an array at least here.
			# maybe I can write eacy to a file?
			temp2.append("#{ary_head},#{head_count}\n")
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
	that.chunked_append
	# color_counts(that)
	

	byebug ; 4
