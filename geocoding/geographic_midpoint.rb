	ABQ = [35.0825301,-106.7466905]
	SF = [35.682558,-106.0181412]
	SOC = [34.0605009,-106.9199575]
	COORDS = [ABQ, SF, SOC]
	PI = 3.1415926.freeze

	def to_cartesian(geocoords)
		lat, lon = geocoords.map{|g| g*PI/180} # to radians
		x = Math.cos(lat) * Math.cos(lon)
		y = Math.cos(lat) * Math.sin(lon)
		z = Math.sin(lat)
		[x, y, z]
	end

	def to_geocoords(cartesian)
		x, y, z = cartesian
		lon = Math.atan2(y, x)
		hyp = (x * x + y * y)**0.5
		lat = Math.atan2(z, hyp)
		[lat, lon].map{|g| g * 180/PI} # to degrees
	end

	def midpoint(coords_ary)
		cart_ary = coords_ary.map{|coords| to_cartesian(coords)}
		cart_avg = cart_ary.transpose.map{|xs| xs.inject(:+)/xs.count.to_f }
		to_geocoords(cart_avg)
	end


puts "the midpoint of ABQ, SANTA FE AND SOCCORO IS #{midpoint(COORDS)}"
