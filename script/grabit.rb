#!/usr/local/bin/ruby 
require 'RestClient'

states = ["DC","AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]

states.each do |state|
  
  csv = RestClient.get( 'https://50.116.48.233/list/'+state+'%20Candidates.csv', 
    {:cookies => {:session => "TwlcEz/Ylza0E1z4pDDW6Kjc9dA=?username=UydidXNvZmVkJwpwMQou"}}
    ) 

  File.open('lib/states/'+state+'.csv', "w+") do |f|
    f.puts csv
  end
  
  puts state
  
end