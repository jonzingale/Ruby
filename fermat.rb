def fermat(num,tol=2)
	[2,3].any?{|i| num == i} ? true :
	[4,6,15].any?{|i| num == i} ? false :
	# (0...tol).map {rand (num/2)}.all?{|a| rmod(a,num) == a}
	fast_list(num/2, tol).all?{|a| rmod(a,num) == a}
end

def rmod base, pow, row=nil
	row = row||pow
	row < 10 ? (base**row) % pow : # find a best value < 10?
	row.even? ? (rmod(base, pow, row/2)**2) % pow :
	(base * rmod(base, pow, row/2)**2) % pow
end

# shuffled_list with a tol
def fast_list len, tol
	lim = (Math.log(4.8265592) * len).floor
	len = tol.nil? ? len : tol
	(0...len).map do
		k = (lim-lim**2)/(2*Math.log(0.5))
		rand(k) % lim
	end
end

# 8 seconds for fermat primes < 1 M
def fprimats(tol=2, lim=100) ; (2..lim).select{|n| fermat n} ; end

puts "#{fprimats}"