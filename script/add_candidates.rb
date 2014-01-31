#!/usr/local/bin/ruby 

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

require 'csv'
require 'active_support/all'
require File.expand_path( File.join(File.dirname(__FILE__), 'process.rb') )

files = ARGV.empty? ? Dir["lib/states/*.csv"] : ARGV


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
        
        newobj = addCandidate(obj)
        
        newFile.push( obj.map{|k,v| v }.to_csv ) if obj['Electoral District'].length == 2
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
