#!/usr/local/bin/ruby 

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

require 'csv'
require 'active_support/all'

files = ARGV.empty? ? Dir["/Users/scott/desktop/new bip/*.csv"] : ARGV


i = 0

collect = []
newFile = []
key = ''

choices = Choice.all.count
options = Option.all.count


files.each do |file|

  row = 0
  key = []
  puts file
  CSV.foreach(file) do |data|
    # begin
      if row != 0
        obj = {}
        ii=0

        data.each do |d|
          unless d.nil?
            obj[ key[ii] ] = ActiveSupport::Inflector.transliterate(d)
          end
          ii+=1
        end

        unless obj['Electoral District'].nil? # A general check - mostly to stop blank rows from proceeding
          
          obj['Electoral District'] = obj['State']+obj['Electoral District'] if obj['Electoral District'].index(obj['State']) != 0  # Appends the state onto the geography if not there
          obj['Electoral District'] = obj['Electoral District'][2] == ' ' ? obj['Electoral District'].slice(0,2)+obj['Electoral District'].slice(3,obj['Electoral District'].length) : obj['Electoral District'] #Removes a space from the front of the geography

          #  Nebraska only has one legislative body - Cicero returns districts as State Upper which cicero.rb codes as SD. So should be translated to Senate Districts
          #  Vermont is also weird - city names for leg districts.

          unless obj['Electoral District'].match(/Congressional|State Senate|State House|State Representative|Legislative District|State Legislature District/).nil?
          
            sep = obj['Electoral District'].split('District')
            obj['Electoral District'] = sep[0]
            number = sep[1].strip.length < 2 ? '0'+sep[1].strip : sep[1].strip
            number = number.length > 2 && number[0] == '0' ? number.slice(1,2) : number
            number = number[2] == 'A' || number[2] == 'B' ? number.slice(0,2)+number.slice(-1).downcase : number
          

            unless obj['Electoral District'].index('Legislative').nil?
              if obj['Office Name'].index('Senator')
                obj['Electoral District'] = obj['Electoral District'].gsub('Legislative','SD')
              else
                obj['Electoral District'] = obj['Electoral District'].gsub('Legislative','HD')
              end
              obj['Office Name'] = obj['Office Name'].split(' - ')[1]
            end

            obj['Electoral District'] = obj['Electoral District'].gsub('Congressional','CD')
            obj['Electoral District'] = obj['Electoral District'].gsub('State Senate','SD')
            obj['Electoral District'] = obj['Electoral District'].gsub('State Legislature District','SD')
            obj['Electoral District'] = obj['Electoral District'].gsub('State House','HD')
            obj['Electoral District'] = obj['Electoral District'].gsub('State Representative','HD')          

            obj['Electoral District'] = obj['Electoral District'].gsub(' ','')+number
          end
        
          obj['Electoral District'] = obj['Electoral District'].gsub('(Muni)','')


          obj['Electoral District'] = obj['Electoral District']
          obj['Office Name'] = obj['Office Name'].split('-')[0].strip
          obj['Office Name'] = obj['Office Name'].split(',')[0].strip
          obj['Office Level'] = 'State' unless obj['Office Level'].index('State').nil?
    
          row_choice = { :geography => obj['Electoral District'], :contest => obj['Office Name'], :contest_type => obj['Office Level'] }
          row_option = { :name => obj['Candidate Name'] }
    
          ['Candidate Party','Website','Twitter Name','Facebook URL','Incumbant'].each do |optional|
            unless obj[optional].nil?
              option_value = optional.downcase
              option_value = 'facebook' if optional == 'Facebook URL'
              option_value = 'party' if optional == 'Candidate Party'
              option_value = 'twitter' if optional == 'Twitter Name'

              row_option[option_value] = obj[optional]

              row_option[option_value] = row_option[option_value].index('http://') == 0 ? row_option[option_value] : 'http://'+row_option[option_value] if option_value == 'website'
              row_option[option_value] = 'http://twitter.com/'+row_option[option_value] if option_value == 'twitter'
              row_option[option_value] = row_option[option_value].downcase == 'true' || row_option[option_value] == '1'  if option_value == 'incumbant'
            end
          end

        
          choice = Choice.find_or_create_by_geography_and_contest( row_choice[:geography],row_choice[:contest],row_choice)    
          if choice.new_record?
            choice.update_attributes(row_choice)
            collect.push( obj['Electoral District'] )
          end
          choice.save
          option = choice.options.find_or_create_by_name( row_option[:name], row_option)
          if option.new_record?
            option.update_attributes(row_option)
          end
          option.save
        
          newFile.push( obj.map{|k,v| v }.to_csv ) if obj['Electoral District'].length == 2
        end
      else
        data.each{ |k|  key.push( k ) }
      end
    # rescue => ex
      # puts file
      # collect.push( file )
      # collect.push( ex )
    # end
    row+=1
    i+=1
    puts i if (i % 100 == 0)
    
  end
  key = key.to_csv
end

puts collect

puts i.to_s+' total rows, adding '+(Choice.all.count-choices).to_s+' Choices and '+(Option.all.count-options).to_s+' options'

if ARGV.empty?
  puts 'Saved to /lib/candidates.csv'

  File.open('lib/candidates.csv', "w+") do |f|
    f.puts key
    f.puts newFile
  end
end