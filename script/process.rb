class Matcher # A class to find choices / options in our DB that NOI has fucked
  @choice
  @option
  
  def choice
    return @choice
  end
  
  def choice= val
    @choice = val
  end

  def option
    return @option
  end
  
  def option= val
    @option = val
  end
  
  
  def initialize obj
    
    geography = obj['Electoral District'].strip 
    contest = obj['Office Name'].strip
    name = obj['Candidate Name'].strip
    
    if obj['UID'] # Search by UID first
      option = Option.find_by_vip_id( obj['UID'] )
      unless option.nil?
        self.choice = option.choice
        self.option = option
        return self
      end
    end
    
    # Now search by geography + contest name - like before
    choice = Choice.find_by_geography_and_contest( geography, contest )
    unless choice.nil?
      self.choice = choice
      option = Option.all( :select => 'options.*', :conditions => ['choice_id = ? AND name LIKE ? AND name LIKE ? ', choice.id, name.split(' ').first+'%','%'+name.split(' ').last ], :limit => 1 ).first
      self.option = option || choice.options.new( :name => name, :vip_id => obj['UID'] )
      return self
    end
    
    # Check by searching the geography for the name
    option = Option.all( :select => 'options.*', :joins => :choice, :conditions => ['geography = ? AND name LIKE ? AND name LIKE ? ', geography, name.split(' ').first+'%','%'+name.split(' ').last ], :limit => 1 ).first
    unless option.nil?
      self.choice = option.choice
      self.option = option
      return self
    end
    
    # Lastly if we really cannot find them - create some new ones
    self.choice = Choice.new( :geography => geography, :contest => contest )
    self.option = self.choice.options.new( :name => name, :vip_id => obj['UID'] )    
    return self
    
  end
  
end

def addCandidate obj
  
  newobj = {}
  
  obj.each do |k,v|
    betterK = k
    betterK = k.split('_').map{|w| w.capitalize }.join(' ') if !betterK.nil? && !betterK.index('_').nil?
    newobj[ betterK ] = v.gsub(/\r/,'').gsub(/\n/,'').strip
  end
  
  obj = newobj

  # Optimized to work with Cicero - i.e. first = First, second = Second, third = 3rd, etc
  ordinals = JSON::parse("{\"first\":\"1st\",\"second\":\"2nd\",\"third\":\"3rd\",\"fourth\":\"4th\",\"fifth\":\"5th\",\"sixth\":\"6th\",\"seventh\":\"7th\",\"eighth\":\"8th\",\"ninth\":\"9th\",\"tenth\":\"10th\",\"eleventh\":\"11th\",\"twelfth\":\"12th\",\"thirteenth\":\"13th\",\"fourteenth\":\"14th\",\"fifteenth\":\"15th\",\"sixteenth\":\"16th\",\"seventeenth\":\"17th\",\"eighteenth\":\"18th\",\"nineteenth\":\"19th\",\"twentieth\":\"20th\",\"twenty-first\":\"21st\",\"twenty-second\":\"22nd\",\"twenty-third\":\"23rd\",\"twenty-fourth\":\"24th\",\"twenty-fifth\":\"25th\",\"twenty-sixth\":\"26th\",\"twenty-seventh\":\"27th\",\"twenty-eighth\":\"28th\",\"twenty-ninth\":\"29th\",\"thirtieth\":\"30th\",\"thirty-first\":\"31st\",\"thirty-second\":\"32nd\",\"thirty-third\":\"33rd\",\"thirty-fourth\":\"34th\",\"thirty-fifth\":\"35th\",\"thirty-sixth\":\"36th\",\"thirty-seventh\":\"37th\",\"thirty-eighth\":\"38th\",\"thirty-ninth\":\"39th\",\"fortieth\":\"40th\",\"forty-first\":\"41st\",\"forty-second\":\"42nd\",\"forty-third\":\"43rd\",\"forty-fourth\":\"44th\",\"forty-fifth\":\"45th\",\"forty-sixth\":\"46th\",\"forty-seventh\":\"47th\",\"forty-eighth\":\"48th\",\"forty-ninth\":\"49th\",\"fiftieth\":\"50th\",\"fifty-first\":\"51st\",\"fifty-second\":\"52nd\",\"fifty-third\":\"53rd\",\"fifty-fourth\":\"54th\",\"fifty-fifth\":\"55th\",\"fifty-sixth\":\"56th\",\"fifty-seventh\":\"57th\",\"fifty-eighth\":\"58th\",\"fifty-ninth\":\"59th\",\"sixtieth\":\"60th\",\"sixty-first\":\"61st\",\"sixty-second\":\"62nd\",\"sixty-third\":\"63rd\",\"sixty-fourth\":\"64th\",\"sixty-fifth\":\"65th\",\"sixty-sixth\":\"66th\",\"sixty-seventh\":\"67th\",\"sixty-eighth\":\"68th\",\"sixty-ninth\":\"69th\",\"seventieth\":\"70th\",\"seventy-first\":\"71st\",\"seventy-second\":\"72nd\",\"seventy-third\":\"73rd\",\"seventy-fourth\":\"74th\",\"seventy-fifth\":\"75th\",\"seventy-sixth\":\"76th\",\"seventy-seventh\":\"77th\",\"seventy-eighth\":\"78th\",\"seventy-ninth\":\"79th\",\"eightieth\":\"80th\",\"eighty-first\":\"81st\",\"eighty-second\":\"82nd\",\"eighty-third\":\"83rd\",\"eighty-fourth\":\"84th\",\"eighty-fifth\":\"85th\",\"eighty-sixth\":\"86th\",\"eighty-seventh\":\"87th\",\"eighty-eighth\":\"88th\",\"eighty-ninth\":\"89th\",\"ninetieth\":\"90th\",\"ninety-first\":\"91st\",\"ninety-second\":\"92nd\",\"ninety-third\":\"93rd\",\"ninety-fourth\":\"94th\",\"ninety-fifth\":\"95th\",\"ninety-sixth\":\"96th\",\"ninety-seventh\":\"97th\",\"ninety-eighth\":\"98th\",\"ninety-ninth\":\"99th\",\"one hundredth\":\"100th\"}" )
  
  if !obj['Electoral District'].nil? && !obj['Office Name'].nil? # A general check - mostly to stop blank rows from proceeding  
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

      if !obj['Electoral District'].index('Legislative').nil? && obj['Electoral District'].index('County Legislative').nil?
        
        # Removing District names for leg districts
        obj['Office Name'] = obj['Office Name'].split('-')[0].strip
        obj['Office Name'] = obj['Office Name'].split(',')[0].strip
        
        if obj['Office Name'].index('Senator')
          obj['Electoral District'] = obj['Electoral District'].gsub('Legislative','SD')
        else
          obj['Electoral District'] = obj['Electoral District'].gsub('Legislative','HD')
        end
        obj['Office Name'] = obj['Office Name'].split(' - ')[0]
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
    obj['Electoral District'] = obj['Electoral District'].gsub('?','')


    obj['Electoral District'] = obj['Electoral District']
    obj['Office Name'] = obj['Office Name'].gsub('#','')
    obj['Office Name'] = obj['Office Name'].gsub('/','-')

    # Codifying some renaming I've done
    obj['Office Name'] = obj['Office Name'].gsub('Commissioner of the Bureau of Labor and Industries','Labor Commissioner') if obj['Electoral District'] == 'OR'
    obj['Office Name'] = obj['Office Name'].gsub('Governor & Lt. Governor','Governor and Lt. Governor') if obj['Electoral District'] == 'MT'
    obj['Electoral District'] += obj['Office Name'].gsub('Commissioner','District') if obj['Electoral District'] == 'MT' && !obj['Office Name'].index('Public Service Commissioner').nil?


    obj['Office Level'] = 'State' unless obj['Office Level'].index('State').nil?
    
    votes = obj['Office Name'].split('Vote for ').length > 1 ? obj['Office Name'].split('Vote for')[1].gsub(')','').to_i : 1

    row_choice = { :votes => votes, :geography => obj['Electoral District'].strip, :contest => obj['Office Name'].strip, :contest_type => obj['Office Level'].strip }
    row_option = { :name => obj['Candidate Name'].strip, :vip_id => obj['UID'].strip }

    ['Candidate Party','Website','Twitter Name','Facebook URL','Incumbant'].each do |optional|
      unless obj[optional].nil?
        option_value = optional.downcase
        option_value = 'facebook' if optional == 'Facebook URL'
        option_value = 'party' if optional == 'Candidate Party'
        option_value = 'twitter' if optional == 'Twitter Name'

        row_option[option_value] = obj[optional].strip

        row_option[option_value] = row_option[option_value].index('http://') == 0 ? row_option[option_value] : 'http://'+row_option[option_value] if option_value == 'website'
        row_option[option_value] = 'http://twitter.com/'+row_option[option_value] if option_value == 'twitter'
        row_option[option_value] =  row_option[option_value].gsub('Democratic','Democrat') if option_value == 'party'
        row_option[option_value] = row_option[option_value].downcase == 'true' || row_option[option_value] == '1'  if option_value == 'incumbant'
      end
    end

    generate = Matcher.new( obj )
    choice = generate.choice
    option = generate.option
    
    if choice.new_record?
      choice.update_attributes(row_choice)
    end
    choice.save

    if option.new_record?
      option.update_attributes(row_option)
    else
      option.party = row_option['party'] if option.party.nil?
      option.party += ', '+row_option['party'] if !row_option['party'].nil? && option.party.index( row_option['party'] ).nil?
      option.website = row_option['website'] if option.website.nil? || option.website.empty?  && !row_option['website'].nil?
      option.facebook = row_option['facebook'] if option.facebook.nil? || option.facebook.empty?  && !row_option['facebook'].nil?
      option.twitter = row_option['twitter'] if option.twitter.nil? || option.twitter.empty?  && !row_option['twitter'].nil?
      option.vip_id = row_option[:vip_id]
    end
    option.save

    return obj
  else
    return false
  end
  
end
