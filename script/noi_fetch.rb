#!/usr/local/bin/ruby 

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

require 'active_support/all'
require 'RestClient'
require File.expand_path( File.join(File.dirname(__FILE__), 'process.rb') )

# Getting the last non-user created 
last = Choice.all( :limit => 1, :conditions => ['geography NOT LIKE ?','%_User_%'], :order => 'created_at DESC', :select => 'choices.created_at' ).first.created_at.to_date.to_s

data = JSON::parse( 
RestClient.get(
  'https://50.116.48.233/list/api?updated='+last,
  {:cookies => {:session => "TwlcEz/Ylza0E1z4pDDW6Kjc9dA=?username=UydidXNvZmVkJwpwMQou"}}
) 
)

puts 'Attempting to add '+data.length.to_s+' new rows of data since '+last

added = 0
choices = Choice.all.count
options = Option.all.count
bad = []

data.each do |row|
  begin
    if newOption = addCandidate(row)
      added += 1
      puts added if (added % 100 == 0)
    else
      bad.push(row)
    end
  rescue Exception => e
     puts e.message  
     puts row
   end
end

puts added.to_s+' total rows, adding '+(Choice.all.count-choices).to_s+' Choices and '+(Option.all.count-options).to_s+' options'

puts bad
