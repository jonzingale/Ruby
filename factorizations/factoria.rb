puts "factoria"

n = 1
while n != 0
 n = gets.chomp.to_i
 def factoria num
  i=1
  j=0
  l=[]
  while i<num**0.5
   if (num%i==0)
    l[j]=i
    l[j+1]=(num/i)
    j=j+2
   end
   i=i+1
  end
  if num**0.5==(num**0.5).floor
   l[j]=(num**0.5).floor
  end #if
  k=l
 end
 k = factoria(n)
 puts k.join(' ')
end # big loop
