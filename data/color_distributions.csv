# super impose over a pic of color wheel
# a disc of hsb values. create fibers
# over the values showing the distribution
# of colors from a source.

# this is almost completely todo as nothing but
# taking from my other code has happened yet.

require 'matrix'
	def setup
		size(600,800) #HOME
		text_font create_font("SanSerif",25) ; no_stroke
		@img = loadImage("/Users/Jon/Desktop/crude/Ruby/data/colorwheel.png")
		@jmg = loadImage("/Users/Jon/Desktop/scans/apollonius.jpg");
		colorMode(HSB,360,100,100)

		background(20) ; frame_rate 3
		@w,@h = [width,height].map{|i|i/2.0}
  	@m = [235,18,85] ; @i = 0
	end

	def	mouseMoved#Dragged#Clicked
		@m = rgb_converter(mouseX,mouseY)
	end

	def rgb_converter(m=0,n=0)
		k = get(m,n)
		r = 256 + k/(256**2)
		g = k/256 % 256
		b = k % 256
		[r,g,b]
	end

	def images
		if @i < 1
			image(@jmg,10,10) # left picture
			scale(5) ; image(@img,width, 10)# ; scale(1/1.0) #Wheel
			scale(0.2) ; image(@img, width-450, 10) ; scale(5/20.0) #APOLLONIUS
			save('/Users/Jon/Desktop/test.png')
			@loaded = loadImage("/Users/Jon/Desktop/test.png")
		else
			image(@loaded,0,0)
		end
	end

	# this whole thing has something
	# going on, but is way too awkward
	# to be right.

	# how do I get hsb values?
	# can they be compared anyway, cleverly?
	def sort_colors(ary,sorted = [])
		if ary.empty? ; sorted ; else
			same, other = ary.partition{|t| t == ary[0] }
			sort_colors(other, sorted << same.count)
		end
		sorted
	end

	def draw
		clear ; images
# eternal things

		@i += 1 % 360 ; fill(0,0,0)

# temporal things
		@loaded = get

		# 201552 pixels
		 @loaded.loadPixels
		 	range = (0...@loaded.pixels.count).to_a
		 	range = range.drop(range.count/1.2)
			range.each{|i| @loaded.pixels[i] =  color(@i,100,100) }

		  it = sort_colors(@loaded.pixels[0..20])
		  text("#{it}",100,200)
		 @loaded.updatePixels

		 text("#{@jmg.pixels[100]}",200,200)
	end





