#!/usr/local/bin/ruby 

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

require 'csv'
require 'active_support/all'

files = ARGV.empty? ? Dir["/Users/scott/desktop/new bip/*.csv"] : ARGV

# Optimized to work with Cicero - i.e. first = First, second = Second, third = 3rd, etc
ordinals = JSON::parse("{\"first\":\"1st\",\"second\":\"2nd\",\"third\":\"3rd\",\"fourth\":\"4th\",\"fifth\":\"5th\",\"sixth\":\"6th\",\"seventh\":\"7th\",\"eighth\":\"8th\",\"ninth\":\"9th\",\"tenth\":\"10th\",\"eleventh\":\"11th\",\"twelfth\":\"12th\",\"thirteenth\":\"13th\",\"fourteenth\":\"14th\",\"fifteenth\":\"15th\",\"sixteenth\":\"16th\",\"seventeenth\":\"17th\",\"eighteenth\":\"18th\",\"nineteenth\":\"19th\",\"twentieth\":\"20th\",\"twenty-first\":\"21st\",\"twenty-second\":\"22nd\",\"twenty-third\":\"23rd\",\"twenty-fourth\":\"24th\",\"twenty-fifth\":\"25th\",\"twenty-sixth\":\"26th\",\"twenty-seventh\":\"27th\",\"twenty-eighth\":\"28th\",\"twenty-ninth\":\"29th\",\"thirtieth\":\"30th\",\"thirty-first\":\"31st\",\"thirty-second\":\"32nd\",\"thirty-third\":\"33rd\",\"thirty-fourth\":\"34th\",\"thirty-fifth\":\"35th\",\"thirty-sixth\":\"36th\",\"thirty-seventh\":\"37th\",\"thirty-eighth\":\"38th\",\"thirty-ninth\":\"39th\",\"fortieth\":\"40th\",\"forty-first\":\"41st\",\"forty-second\":\"42nd\",\"forty-third\":\"43rd\",\"forty-fourth\":\"44th\",\"forty-fifth\":\"45th\",\"forty-sixth\":\"46th\",\"forty-seventh\":\"47th\",\"forty-eighth\":\"48th\",\"forty-ninth\":\"49th\",\"fiftieth\":\"50th\",\"fifty-first\":\"51st\",\"fifty-second\":\"52nd\",\"fifty-third\":\"53rd\",\"fifty-fourth\":\"54th\",\"fifty-fifth\":\"55th\",\"fifty-sixth\":\"56th\",\"fifty-seventh\":\"57th\",\"fifty-eighth\":\"58th\",\"fifty-ninth\":\"59th\",\"sixtieth\":\"60th\",\"sixty-first\":\"61st\",\"sixty-second\":\"62nd\",\"sixty-third\":\"63rd\",\"sixty-fourth\":\"64th\",\"sixty-fifth\":\"65th\",\"sixty-sixth\":\"66th\",\"sixty-seventh\":\"67th\",\"sixty-eighth\":\"68th\",\"sixty-ninth\":\"69th\",\"seventieth\":\"70th\",\"seventy-first\":\"71st\",\"seventy-second\":\"72nd\",\"seventy-third\":\"73rd\",\"seventy-fourth\":\"74th\",\"seventy-fifth\":\"75th\",\"seventy-sixth\":\"76th\",\"seventy-seventh\":\"77th\",\"seventy-eighth\":\"78th\",\"seventy-ninth\":\"79th\",\"eightieth\":\"80th\",\"eighty-first\":\"81st\",\"eighty-second\":\"82nd\",\"eighty-third\":\"83rd\",\"eighty-fourth\":\"84th\",\"eighty-fifth\":\"85th\",\"eighty-sixth\":\"86th\",\"eighty-seventh\":\"87th\",\"eighty-eighth\":\"88th\",\"eighty-ninth\":\"89th\",\"ninetieth\":\"90th\",\"ninety-first\":\"91st\",\"ninety-second\":\"92nd\",\"ninety-third\":\"93rd\",\"ninety-fourth\":\"94th\",\"ninety-fifth\":\"95th\",\"ninety-sixth\":\"96th\",\"ninety-seventh\":\"97th\",\"ninety-eighth\":\"98th\",\"ninety-ninth\":\"99th\",\"one hundredth\":\"100th\"}" )

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
          
          obj['Electoral District'] = obj['Electoral District'].slice(0,2).upcase+obj['Electoral District'].slice(2,obj['Electoral District'].length) # Always upcase
          
          #  Nebraska only has one legislative body - Cicero returns districts as State Upper which cicero.rb codes as SD. So should be translated to Senate Districts
          #  Vermont is also weird - city names for leg districts.
          
          # Handling districts
          unless obj['Electoral District'].match(/Congressional|State Senate|State House|State Representative|Legislative District|State Legislature District/).nil?
          
            sep = obj['Electoral District'].split('District')
            obj['Electoral District'] = sep[0]

            if sep.length > 1
              number = sep[1].strip.length < 2 ? '0'+sep[1].strip : sep[1].strip
              number = number.length > 2 && number[0] == '0' ? number.slice(1,2) : number
              number = number[2] == 'A' || number[2] == 'B' ? number.slice(0,2)+number.slice(-1).downcase : number
              number = number.gsub(' ','-')
            end
            
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
            obj['Electoral District'] = obj['Electoral District'].gsub('NEState Legislature','NESD')
            obj['Electoral District'] = obj['Electoral District'].gsub('State House','HD')
            obj['Electoral District'] = obj['Electoral District'].gsub('State Representative','HD')          
            
            if number.nil? # Mostly for MA

              if obj['Electoral District'].slice(0,4) == 'MAHD'
                district = obj['Electoral District'].slice(5,obj['Electoral District'].length)
                ordinal = district.split(' ')[0]
                obj['Electoral District'] = obj['Electoral District'].gsub( ordinal,ordinals[ ordinal.downcase ])  unless ordinals[ ordinal.downcase ].nil?
              end

              obj['Electoral District'] = obj['Electoral District'].slice(0,4) + obj['Electoral District'].slice(5, obj['Electoral District'].length ) if obj['Electoral District'][4] == ' '
              obj['Electoral District'] = obj['Electoral District'].strip
            end
            
            if obj['Electoral District'].slice(0,2) == 'NH'
              number = ' '+number.to_i.to_s
              obj['Electoral District'] = obj['Electoral District'].gsub('-','')
            end

            obj['Electoral District'] = obj['Electoral District'].gsub(' ','')+number unless number.nil?
            obj['Office Name'] = obj['Office Name'].gsub(', Position',' Pos')
          end
          
          
          obj['Electoral District'] = obj['Electoral District'].gsub('(Muni)','')


          obj['Electoral District'] = obj['Electoral District']
          
          obj['Office Name'] = obj['Office Name'].split('-')[0].strip
          obj['Office Name'] = obj['Office Name'].split(',')[0].strip
          obj['Office Name'] = obj['Office Name'].gsub('#','')
          
          # Codifying some renaming I've done
          obj['Office Name'] = obj['Office Name'].gsub('Commissioner of the Bureau of Labor and Industries','Labor Commissioner') if obj['Electoral District'] == 'OR'
          obj['Office Name'] = obj['Office Name'].gsub('Governor & Lt. Governor','Governor and Lt. Governor') if obj['Electoral District'] == 'MT'
          obj['Electoral District'] += obj['Office Name'].gsub('Commissioner','District') if obj['Electoral District'] == 'MT' && !obj['Office Name'].index('Public Service Commissioner').nil?


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