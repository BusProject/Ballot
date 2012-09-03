require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

require 'csv'
require 'active_support/all'

i = 0
collect = []

choices = Choice.all.count
options = Option.all.count

puts 'start!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'



row = 0
key = []
file = "/Users/scott/Dropbox/Bus Project/ballot css/ballotmeasures.csv"
CSV.foreach(file) do |data|
  begin
    if row != 0
      obj = {}
      ii=0

      data.each do |d|
        unless d.nil?
          obj[ key[ii] ] = d# ActiveSupport::Inflector.transliterate(d)
        end
        ii+=1
      end



      row_choice = { :geography => obj['State'], :contest => obj['Title'], :contest_type => 'Ballot_Statewide', :description => obj['Subtitle'] }
      row_option1 = { :name => obj['Response 1'], :blurb => obj['Response 1 Blurb'], :blurb_source => obj['Text'] }
      row_option2 = { :name => obj['Response 2'], :blurb => obj['Response 2 Blurb'], :blurb_source => obj['Text'] }
      puts obj['Text']
      choice = Choice.find_or_create_by_geography_and_contest( row_choice[:geography],row_choice[:contest],row_choice)    
      choice.update_attributes(row_choice)
      choice.save
      option = choice.options.find_or_create_by_name( row_option1[:name], row_option1)
      option.update_attributes(row_option1)
      option.save
      
      option = choice.options.find_or_create_by_name( row_option2[:name], row_option2)
      option.update_attributes(row_option2)
      option.save
      
    else
      data.each{ |k|  key.push( k ) }
    end
  rescue => ex
    puts file
    collect.push( file )
    collect.push( ex )
  end
  row+=1
  i+=1
  puts i if (i % 100 == 0)
  
end



puts collect
puts 'done!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
puts i.to_s+' total rows, adding '+(Choice.all.count-choices).to_s+' Choices and '+(Option.all.count-options).to_s+' options'
