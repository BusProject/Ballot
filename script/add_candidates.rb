require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

require 'csv'
require 'active_support/all'

files = Dir["/Users/scott/Dropbox/Bus Project/ballot css/bip/*.csv"]
i = 0
collect = []

choices = Choice.all.count
options = Option.all.count

puts 'start!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'

files.each do |file|

  row = 0
  key = []
  puts file
  CSV.foreach(file) do |data|
    begin
      if row != 0
        obj = {}
        ii=0

        data.each do |d|
          unless d.nil?
            obj[ key[ii] ] = ActiveSupport::Inflector.transliterate(d)
          end
          ii+=1
        end

        obj['Electoral District'] = obj['State']+obj['Electoral District'] if obj['Electoral District'].index(obj['State']) != 0
obj['Electoral District'] = obj['Electoral District'][2] == ' ' ? obj['Electoral District'].slice(0,2)+obj['Electoral District'].slice(3,obj['Electoral District'].length) : obj['Electoral District']

        unless obj['Electoral District'].match(/Congressional|State Senate|State House|State Representative|Legislative District/).nil?
          
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
        choice.update_attributes(row_choice)
        choice.save
        option = choice.options.find_or_create_by_name( row_option[:name], row_option)
        option.update_attributes(row_option)
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

end

puts collect
puts 'done!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
puts i.to_s' total rows, adding '+(Choice.all.count-choices).to_s+' Choices and '+(Option.all.count-options).to_s+' options'
