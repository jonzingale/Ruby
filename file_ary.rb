	# treat files like arrays.
	require 'byebug'
	FILES_PATH = File.expand_path('./../data', __FILE__)
	EXAMPLE = "#{FILES_PATH}/color_distributions.csv"
	FILE1 = "#{FILES_PATH}/file1.csv"
	FILE2 = "#{FILES_PATH}/file2.csv"


	class FileAry
		# keep things as strings.
		attr_accessor :read, :head, :lines, :path
		def initialize(path)
			@path = path
			@read = File.open(path,'r').read
			@head = read.lines.first
			@lines = read.lines
		end

		def same_as_first_count
			self.lines.count{|i| self.head == i }
		end	

		def append(content)
			File.open(path,'a'){|file| file << content}
		end

		def copy(trg)
			File.open(trg.path,'w'){|file| file << self.read}
		end

		def delete_same_as(content)
			self.lines.reject!{|line| line == content}
		end

		def rename(trgt,new_name_str)
			File.rename(@path, new_name_str)
		end

	end
	# 	# POSTPROCESSING
	# 	def sort_csv_processor
	# 		File.open(COLOR_FILE2, 'w')
	# 		csv = CSV.read(COLOR_FILE)
	# 		sort_colors_in_file(csv)
	# 	end
	
	# 	def sort_colors_in_file(ary)
	# 		until ary.empty?
	# 			ins, ary = ary.partition{|color,count| color == ary[0][0] }
	
	# 			count = ins.map{|col,cnt| cnt.to_i}.inject :+
	# 			color = ins[0][0]
	
	# 			CSV.open(COLOR_FILE2, 'a'){|csv| csv << [color,count] }
	# 			sort_colors_in_file(ary)
	# 		end
	# 	end


	it = FileAry.new(FILE1)
	that = FileAry.new(FILE2)

that.delete_same_as(it.head)

	byebug ; 4
