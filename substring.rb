require 'byebug'

str = "redbluegreengreenblue"
ptn = "abccb"

str2 = "redblueredblue"
ptn2 = 'abab'

def getR pt
  pt.chars.inject("") {|acc, c| acc + '(\w{%d})'}
end

def baseK (k, n)
  n == 0 ? [] : baseK(k, (n/k)) << n % k
end

def innerProd (ary, bry)
  ary.zip(bry).inject(0) {|acc, bs| acc += bs.inject(1, :*)}
end

def counts (ary)
  if ary == [] ; []
  else
    (hh,tt) = ary.partition {|a| a == ary[0]}
    counts(tt).unshift(hh.length)
  end
end

def allValid (ptn, str)
  ptns = ptn.split('')
  ps = ptns.uniq.length # number of unique pattern types
  poly = counts ptns # number of pattern multiplicities
  ms = (str.length ** (ps-1)...str.length ** ps).inject([]) do |acc, i|
    vs = baseK(str.length, i) # n-ary reps
    cond = vs.all? {|t| t > 0} && # no patterns should be empty
           innerProd(poly, vs) == str.length # solves polynomial
    cond ? acc << vs : acc
  end
end

def splittings (ptn, str)
  ptnU = ptn.split('').uniq

  allValid(ptn, str).map do |kv|
    ary = ptnU.zip(kv).inject(ptn) do |p, (pu, v)|
      p = p.gsub(pu, v.to_s)
    end.split('').map(&:to_i)

    str.match(getR(ptn) % ary)[1..ptn.length]
  end
end

def hasPattern? (ptn, str)
  ptV = splittings(ptn,str).any? do |ss|
    ss, pt = ss.uniq, ptn
    while (!pt.nil? && !pt.empty?)
      pt = pt.delete(pt[0])
      ss.shift
    end
    pt.length == ss.length
  end

  result = ptV ? "Has Pattern\n" : "Fails Pattern\n"
  print result
end

hasPattern?(ptn,str)
hasPattern?(ptn2, str2)
hasPattern?(ptn2, str)
hasPattern?(ptn, str2)