#!/usr/local/bin/ruby 

# require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
require 'RestClient'
require 'nokogiri'
require 'json'

#  Should move this somewhere else
class String
  def proper
    return self.split(' ').map{ |f| f.capitalize }.join(' ')
  end
end

# Create a name for the district
def makeGeography officestring, state
  geography = officestring
  office = officestring
  number = geography.match(/\d+/) # Identifies if there's a district number
  
#  Ignoring for now - will just add geographies by hand
  # unless number.nil? # No district number - assume it's not a districted office
  #   number = number.to_s
  #   number = '0'+number if number.length < 2
  #   
  # end
  
  backmatcher = ['city of','town of','village of'] # List of offices that 
  
  backmatcher.each do |matcher|
    geography = geography.downcase.split(matcher).last.proper unless geography.downcase.index(matcher).nil?
  end
  
  return state+geography

end

# Processes the Lousiana's SOS's candidate page's html
def processLA page,choices=nil,parish=nil
  choices = choices || []
  
  doc = Nokogiri::HTML(page)

  headings = doc.css('table.raceHeading')
  candidates = doc.css('table.candidate')

  headings.count.times do |index|
  
    raceTable = headings[index]
    candidateTable = candidates[index]
  
    choice = {}
    choice[:options] = []
  
    # Extracting the race information
    choice[:contest] = raceTable.css('th').first.content
    choice[:votes] = raceTable.css('th').last.content.slice(0,1).to_i
    
    geography = makeGeography( choice[:contest],'LA' )
    geography = ['LA',parish,' Parish ',geography.slice(2,500).join('') if geography.slice(2,500) == choice[:contest] && !parish.nil?
    choice[:geography] = geography
    choice[:geography] = choice[:geography].gsub('Member of','').gsub('  ',' ')
    
    if choices.select{ |searching| searching[:contest] == choice[:contest] }.empty?
    
      option = {}
      option[:name] = candidateTable.css('tr:nth-child(2) td:first-child').first.content
      option[:party] = candidateTable.css('tr:nth-child(2) td:last-child').first.content
      choice[:options].push( option )
  
      option = {}
      option[:name] = candidateTable.css('tr:nth-child(5) td:first-child').first.content
      option[:party] = candidateTable.css('tr:nth-child(5) td:last-child').first.content
      choice[:options].push( option )

      choices.push( choice )
    end
  end
  
  return choices
  
end

choices = []
electionid = '260'
@parishes = JSON::parse('{"2":"Acadia","3":"Allen","4":"Ascension","5":"Assumption","6":"Avoyelles","7":"Beauregard","8":"Bienville","9":"Bossier","10":"Caddo","11":"Calcasieu","12":"Caldwell","13":"Cameron","14":"Catahoula","15":"Claiborne","16":"Concordia","17":"De Soto","18":"East Baton Rouge","19":"East Carroll","20":"East Feliciana","21":"Evangeline","22":"Franklin","23":"Grant","24":"Iberia","25":"Iberville","26":"Jackson","27":"Jefferson","28":"Jefferson Davis","29":"Lafayette","30":"Lafourche","31":"Lasalle","32":"Lincoln","33":"Livingston","34":"Madison","35":"Morehouse","36":"Natchitoches","37":"Orleans","38":"Ouachita","39":"Plaquemines","40":"Pointe Coupee","41":"Rapides","42":"Red River","43":"Richland","44":"Sabine","45":"St. Bernard","46":"St. Charles","47":"St. Helena","48":"St. James","49":"St. John The Baptist","50":"St. Landry","51":"St. Martin","52":"St. Mary","53":"St. Tammany","54":"Tangipahoa","55":"Tensas","56":"Terrebonne","57":"Union","58":"Vermilion","59":"Vernon","60":"Washington","61":"Webster","62":"West Baton Rouge","63":"West Carroll","64":"West Feliciana","65":"Winn"}')

statewide = RestClient.post( 
  'https://candidateinquiry.sos.la.gov/Statewide/CandidateList',
  'electionId='+electionid+'&officeIds=47291&officeIds=47252&officeIds=47277&officeIds=47278&officeIds=47275'
)

choices = processLA( statewide, choices)

65.times do |parishNumber|
 parish = RestClient.get 'https://candidateinquiry.sos.la.gov/Parish/RacesInParish?electionId='+electionid+'&parishId='+parishNumber.to_s
 parishName = @parishes[parishNumber.to_s]
 choices = processLA(parish,choices,parishName)
 puts parishName
end

File.open('dump.json', "w") do |f|
  f.puts choices.to_json
end

