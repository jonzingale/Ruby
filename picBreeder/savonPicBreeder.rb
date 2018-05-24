require 'rubygems'
require 'byebug'
require "savon"

OPERATIONS = [:authenticate, :get_anonymous_entry, :at_unpublished_limit,
              :get_new_series_id, :get_generations, :get_representative_genome,
              :get_series_xml, :save_series]

msg1 = {message: { userName: "jzingale", password: "qa1234", sid: 1}}
msg2 = {message: { userName: "jzingale", password: "qa1234", pid: 1}}


client = Savon.client(wsdl: "http://www.picbreeder.org:8080/axis/services/WebNeatClient?wsdl",
                      follow_redirects: true)

response = client.call(:authenticate, message: { userName: "jzingale", password: "qa1234" })
puts response.body

# id_resp = client.call(:get_new_series_id, msg2)

# series_resp = client.call(:get_series_xml, message: { userName: "jzingale", password: "qa1234", sid: 1})
# puts response.hash

# anon_resp = client.call(:get_anonymous_entry, message: { sid: 1})

byebug;
4