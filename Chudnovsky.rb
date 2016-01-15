# Chudnovsky algorithm
# good upto n =27

def fact(n)
  n < 2 ? 1.0 : (1..n).inject(1.0) {|fac,n| n*fac}
end

def summation(list)
	list.inject {|summ,l| summ+l}
end

def numerator(k)
	(-1.0)**k * (fact(6*k)) * (13591409.0 + 545140134.0*k)
end

def denominator(k)
	(fact(3.0*k)) * ((fact k)**3) * (640320.0**( (3*k+3.0/2.0) ))
end

def terms(n)
	(0..n).map{|k| numerator(k) / denominator(k)} 
end

def chudnovsky(n)
	(12.0*(summation(terms(n)))).to_f ** (-1.0)
end

n = gets.chomp.to_i
chudnovsky n