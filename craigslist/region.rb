class Region
	require 'matrix'
	
	RADII_BLACKLIST = ['sfuad'].freeze

	JACKRABBIT = [35.689054,-105.946113]
	MY_HOUSE = [35.680067,-105.962163]
	ST_JOHNS = [35.671955,-105.913378]
	BUCKMAN  = [35.698446,-105.9832] # default
	COORDS = [BUCKMAN,MY_HOUSE,ST_JOHNS].freeze

	def initialize(lat,long) ; @point = [lat,long] ; end

	def jordan(miles) ; coord_dist(JACKRABBIT,@point) < miles ; end

	def coord_dist(here_coords,there_coords) # COORDS -> COORDS -> FLOAT
		unless (places = [here_coords,there_coords]).any?(&:empty?)
			lat1, lon1, lat2, lon2 = places.flatten
			phi1, phi2 = [lat1, lat2].map{|d| d * Math::PI / 180 } # in radians
			d_phi, d_lam = [lat2 - lat1, lon2 - lon1].map{|x| x * Math::PI / 180 }
		
			arc = Math.sin(d_phi/2.0) * Math.sin(d_phi/2.0) +
			    	Math.cos(phi1) * Math.cos(phi2) *
			    	Math.sin(d_lam/2.0) * Math.sin(d_lam/2.0)
		
			cir = 2 * Math.atan2(Math.sqrt(arc), Math.sqrt(1-arc))
			distance = 3959 * cir # in miles
		end
	end

	def orth(vect) 
		x,y = vect.to_a
		Vector.elements([-y,x])
	end

	def inner(vect,wect) # what if vect or wect is a scalar?
		dot = [vect,wect].map(&:to_a).transpose.map{|p| p.inject(1,:*)}.inject(0,:+)
	end

	def in_region? # GEOCOORDS -> STRING
		b, a, c = COORDS.map{|v|Vector.elements(v)}
		pt = Vector.elements(@point) - a
		# perpendiculars have opposite signs.
		acute_cond =  inner(b - a, orth(a - c)) > 0
		_B = inner(pt, orth(b - a)) >= 0
		_C = inner(pt, orth(a - c)) >= 0
		cond = acute_cond ? _B & _C : _B | _C
		jordan(2.0) && cond
	end

end
