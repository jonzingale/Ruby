	def setup
		text_font create_font("SanSerif",10);
		# size(1920,1080) #JackRabbit
		square = [1080] * 2  + [P3D] # 800
		@w,@h = [square[0]/2] * 2
		size(*square) ; @bs = [height,width].min
		@i, @t = [0] * 2 ; background(0)
		@colors = (0..3).map{|i|rand(255)}
		frame_rate 20 ; colorMode(HSB,360,100,100)
		no_fill() ; lights() ; no_stroke
	end

	def text_block(string='')
		fill(0,0,0) ; no_stroke
		rect(@w-40,@h-40,@w+40,@h+40)
		fill(200, 140, 0)
		text(string,@w,@h)
	end

	def draw
		omega = 360 * 5 ; r = 360
		@i = (@i+1) % omega #; @t += 1 if @i == 120
		x,y = %w(sin cos).map{|s| Math.send(s, 2*PI*@i/360) }
		# fill(@i%360,100,100) ; ellipse(r*x+@w,r*y+@h,10,10)

		fill(@i%360,100,100-(@i/(3.6*5)))
		ellipse((r-@i/5.0)*x+@w,(r-@i/5.0)*y+@h,30,30)
		# set((r-@i/2.0)*x+@w,(r-@i/2.0)*y+@h,color(@i%360,100,100))
	end
