# This ruby-processing file generates the group
# multiplication table for a group of units of n,
# given an integer n.

	# Todo: better auto rescaling; change n on keystroke.
	def setup
		background(0)
		zahlen = 119# <-- change integer here.
		@table = color_it(rsa_group(zahlen))
		square = [1000] * 2 ; size(*square)
		frame_rate 1 ; colorMode(HSB,360,100,100)
	end

	def pretty_print(board)
		scale = width/board[0].length*0.9
		board.each_with_index do |row,c_dex|
			row.each_with_index do |c,r_dex|
				x,y = [r_dex,c_dex].map{|i|i*scale+50}
				fill(c,100,100) ; ellipse(x,y,scale,scale)
			end
		end
	end

	def rsa_group(int)
		non_factors = (1...int).select{|i|i.gcd(int)==1}
		non_factors.inject([]){|is,i| is << (non_factors).map{|j| i*j%int} }
	end

	def color_it(table)
		roots_color = (1..table.length).map{|n|360*n/(table.length)}
		apply_color = table.map do |k|
			keyed = k.zip(table[0]).sort.zip(roots_color)
			keyed.sort_by{|i|i[0][1]}.map(&:last)
		end
	end

	def draw
		pretty_print(@table)
	end
