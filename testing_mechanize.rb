require 'mechanize'
require 'byebug'
# mechanize (2.7.3)

agent = Mechanize.new
agent.ssl_version = 'SSLv3'
byebug

agent.post('https://reservations.devilsthumbranch.com/VCI/gawrgett.cgi','ADULTS=1&CHILDREN=0&groupcode=&package=&arrivaldate=11%2F17%2F2015&departuredate=11%2F18%2F2015&B1=ACCEPT+DATES&groupcode=&package1=&package=&packagedesc=&coupon=&ordernumber=&arrivemonth=&arriveday=&arriveyear=&departmonth=&departday=&departyear=&company=01&terminal=98&propertyname=Devil%27s+Thumb+Ranch+Resort%26Spa&daysstay=000&selectedtype=&details=&selecteddesc=&totalprice=&depositrequired=&roomrate=&roomonly=&name=&authorization=&cardnumber=&cardexp=&address=&city=&state=&country=&zipcode=&phone=&fax=&email=&mode=S2&TempVar1=&TempVar2=&TempVar3=&TempVar4=&TempVar5=AllRooms&Var01=&Var02=&Var03=&Var04=&Var05=&Var06=&Var07=&Var08=&Var09=&Var10=&Var11=&Var12=&Var13=&Var14=&Var15=&Var16=&Var17=&Var18=&Var19=&Var20=')

# curl --sslv3 'https://reservations.devilsthumbranch.com/VCI/gawrgett.cgi' --data 'ADULTS=1&CHILDREN=0&groupcode=&package=&arrivaldate=11%2F17%2F2015&departuredate=11%2F18%2F2015&B1=ACCEPT+DATES&groupcode=&package1=&package=&packagedesc=&coupon=&ordernumber=&arrivemonth=&arriveday=&arriveyear=&departmonth=&departday=&departyear=&company=01&terminal=98&propertyname=Devil%27s+Thumb+Ranch+Resort%26Spa&daysstay=000&selectedtype=&details=&selecteddesc=&totalprice=&depositrequired=&roomrate=&roomonly=&name=&authorization=&cardnumber=&cardexp=&address=&city=&state=&country=&zipcode=&phone=&fax=&email=&mode=S2&TempVar1=&TempVar2=&TempVar3=&TempVar4=&TempVar5=AllRooms&Var01=&Var02=&Var03=&Var04=&Var05=&Var06=&Var07=&Var08=&Var09=&Var10=&Var11=&Var12=&Var13=&Var14=&Var15=&Var16=&Var17=&Var18=&Var19=&Var20='


byebug ; 4