class Meme < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  attr_accessible :image, :quote, :feedback, :theme
  
  belongs_to :feedback
  has_one :user, :through => :feedback
  has_one :option, :through => :feedback



  
  def shareText
    return ['"'+self.quote+'" - ',self.user.name,self.user.to_url(true)].join(' ')
  end
  
  def fbMeme user = self.user, current_token

    
    me = FbGraph::User.me( current_token )
    message = self.shareText

    photo = me.photo!( :source => self.makeFile, :message => message )

    
    self.fb = 'https://www.facebook.com/photo.php?fbid='+photo.identifier
    self.save if user == self.user

    return self.fb
  end
  
  def makeBlob
    require 'RMagick'
    if self.new_record? || !File.exists?( self.getTMP )
      img = self.generate
      img.write self.getTMP
    else
      img = Magick::Image.read( self.getTMP ).first
    end
    return img.to_blob
  end
  
  def makeFile
    if self.new_record? || !File.exists?( self.getTMP )
      img = self.generate
      img.write self.getTMP
      img = File.open( self.getTMP )
    else
      img = File.open( self.getTMP )
    end
    return img
  end
  
  def generate
    require 'RMagick'


    text = self.quote || ' '
    theme = self.theme || 'yes/1.jpg'
    theme = theme.gsub('/assets/','')

    text.slice(0,140)
    flavor = ['no','against','opposed'].index( self.option.name.downcase ) ? 'no' : 'yes'
    contest = self.option.choice.contest.split(' ')[0]
    number = self.option.choice.contest.split(' ')[1]
    
    themes = {
      'yes/1.jpg' => {
        'quote' => { :font => 'lib/assets/Museo_Slab_500.otf', :size => 35, :align => Magick::CenterAlign,:left => 250,:shadow => true,:top => 10+( ( text.length/28 > 3 ? 0 : 3 - text.length/28 ) )*38,:chars => 27,:text => "''"+text+"''" },
        'name' => {:font => 'lib/assets/Museo_Slab_500.otf',:size => 20,:align => Magick::RightAlign,:left => 480,:shadow => true,:top => 280,:text => '- '+self.user.first_name+' '+self.user.last_name },
        'measure' => {:font => 'lib/assets/League_Gothic.otf',:size => 44,:left => 40,:top => 444,:text => ['On',contest,number].join(' ').upcase,:fill => 'transparent',:stroke => 'white',:weight => Magick::NormalWeight},
      },
      'yes/2.jpg' => {
        'quote' => {:font => 'lib/assets/Haymaker.ttf',:size => 20,:align => Magick::CenterAlign,:left => 250,:top => 284+( ( text.length/32 > 2 ? 0 : 2 - text.length/32 ) )*20,:chars => 32,:text => "''"+text+"''",:fill => 'black'},'name' => {:font => 'lib/assets/Wisdom_Script.otf',:size => 20,:align => Magick::CenterAlign,:left => 250,:top => 410,:text => '- '+self.user.first_name+' '+self.user.last_name,:fill => 'black'},
        'measure' => {:font => 'lib/assets/Wisdom_Script.otf',:size => 36,:left => 250,:top => 120,:text => 'On '+contest.capitalize,:fill => 'black',:align => Magick::CenterAlign},
        'numba' => {:font => 'lib/assets/Haymaker.ttf',:size => 80,:left => 244,:top => 150,:text => number,:fill => 'black',:align => Magick::CenterAlign }
      },
      'yes/3.jpg' => {
        'quote' => {:font => 'lib/assets/ONRAMP.ttf',:size => 40,:left => 20,:top => 120+( ( text.length/28 > 2.5 ? 0 : 2.5 - text.length/28 ) )*44,:chars => 27,:text => "''"+text+"''",:fill => '#5a663e' },
        'name' => {:font => 'lib/assets/Museo_Slab_500italic.otf',:size => 20,:left => 20,:top => 410,:text => self.user.first_name+' '+self.user.last_name,:fill => '#5a663e' },
        'measure' => {:font => 'lib/assets/ONRAMP.ttf',:size => 50,:left => 24,:top => 68,:text => ['On',contest,number].join(' ').upcase,:fill => '#d37a3c', }
      },
      'yes/4.jpg' => {
        'quote' => {:font => 'lib/assets/Museo_Slab_500.otf',:size => 26,:left => 16,:shadow => true,:top => 200+( ( text.length/28 > 2 ? 0 : 2 - text.length/28 ) )*38,:chars => 27,:text => "''"+text+"''" },
        'name' => {:font => 'lib/assets/Museo_Slab_500italic.otf',:size => 20,:left => 16,:top => 390,:text => self.user.first_name+' '+self.user.last_name,:fill => 'white',:shadow => true},
        'on' => {:font => 'lib/assets/Museo_Slab_500.otf',:size => 28,:left => 310,:top => 40,:text => 'on '+contest.downcase,:fill => 'white',:shadow => true},
        'measure' => {:font => 'lib/assets/Museo_Slab_500.otf',:size => 28,:left => 310,:top => 70,:text => self.option.choice.contest.gsub('Measure','').strip().upcase(),:fill => 'white',:shadow => true},
        'this' => {:font => 'lib/assets/Museo_Slab_500.otf',:size => 28,:left => 310,:top => 100,:text => 'this election',:fill => 'white',:shadow => true}
      },
      'no/1.jpg' => { 
        'quote' => {:font => 'lib/assets/Museo_Slab_500.otf',:size => 35,:align => Magick::CenterAlign,:left => 250,:shadow => true,:top => 10+( ( text.length/28 > 3 ? 0 : 3 - text.length/28 ) )*38,:chars => 27,:text => "''"+text+"''", },
        'name' => {:font => 'lib/assets/Museo_Slab_500.otf',:size => 20,:align => Magick::RightAlign,:left => 480,:shadow => true,:top => 280,:text => '- '+self.user.first_name+' '+self.user.last_name, },
        'measure' => {:font => 'lib/assets/League_Gothic.otf',:size => 44,:left => 40,:top => 444,:text => ['On',contest,number].join(' ').upcase,:fill => 'transparent',:stroke => 'white',:weight => Magick::NormalWeight},
      },
      'no/2.jpg' => {
        'quote' => {:font => 'lib/assets/Haymaker.ttf',:size => 20,:align => Magick::CenterAlign,:left => 250,:top => 284+( ( text.length/32 > 2 ? 0 : 2 - text.length/32 ) )*20,:chars => 32,:text => "''"+text+"''",:fill => 'black' },
        'name' => {:font => 'lib/assets/Wisdom_Script.otf',:size => 20,:align => Magick::CenterAlign,:left => 250,:top => 410,:text => '- '+self.user.first_name+' '+self.user.last_name,:fill => 'black' },
        'measure' => {:font => 'lib/assets/Wisdom_Script.otf',:size => 36,:left => 250,:top => 120,:text => 'On '+contest.capitalize,:fill => 'black',:align => Magick::CenterAlign },
        'numba' => {:font => 'lib/assets/Haymaker.ttf',:size => 80,:left => 244,:top => 150,:text => number,:fill => 'black',:align => Magick::CenterAlign }
      },
      'no/3.jpg' => {
        'quote' => {:font => 'lib/assets/ONRAMP.ttf',:size => 40,:left => 20,:top => 120+( ( text.length/28 > 2.5 ? 0 : 2.5 - text.length/28 ) )*44,:chars => 27,:text => "''"+text+"''",:fill => '#ffbabc' },
        'name' => {:font => 'lib/assets/Museo_Slab_500italic.otf',:size => 20,:left => 20,:top => 410,:text => self.user.first_name+' '+self.user.last_name,:fill => '#ffbabc' },
        'measure' => {:font => 'lib/assets/ONRAMP.ttf',:size => 50,:left => 24,:top => 68,:text => ['On',contest,number].join(' ').upcase,:fill => 'white' }
      },
      'no/4.jpg' => {
        'quote' => {:font => 'lib/assets/Museo_Slab_500.otf',:size => 26,:left => 16,:shadow => true,:top => 200+( ( text.length/28 > 2 ? 0 : 2 - text.length/28 ) )*38,:chars => 27,:text => "''"+text+"''" },
        'name' => {:font => 'lib/assets/Museo_Slab_500italic.otf',:size => 20,:left => 16,:top => 390,:text => self.user.first_name+' '+self.user.last_name,:fill => 'white',:shadow => true },
        'on' => {:font => 'lib/assets/Museo_Slab_500.otf',:size => 28,:left => 310,:top => 40,:text => 'on '+contest.downcase,:fill => 'white',:shadow => true },
        'measure' => {:font => 'lib/assets/Museo_Slab_500.otf',:size => 28,:left => 310,:top => 70,:text => self.option.choice.contest.gsub('Measure','').strip().upcase(),:fill => 'white',:shadow => true },
        'this' => {:font => 'lib/assets/Museo_Slab_500.otf',:size => 28,:left => 310,:top => 100,:text => 'this election',:fill => 'white',:shadow => true }
      },
      'special/gosling.jpg' => {
        'hey girl' => {:font => 'lib/assets/League_Gothic.otf',:size => 80,:left => 20,:top => 10,:fill => 'black',:text => 'Hey Girl' },
        'message' => {:font => 'lib/assets/League_Gothic.otf',:size => 40,:left => 20,:top => 120,:chars => 17,:fill => 'black',:text => text.gsub(/hey girl/i,'') },
        'vote' => {:font => 'lib/assets/ONRAMP.ttf',:size => 50,:align => Magick::RightAlign,:left => 498,:top => 380,:fill => flavor === 'no' ? 'red' : '#5a663e',:text => 'Vote '+flavor.capitalize },
        'measure' => {:font => 'lib/assets/ONRAMP.ttf',:size => 30,:align => Magick::RightAlign,:left => 496,:top => 420,:fill => flavor === 'no' ? 'red' : '#5a663e',:text => [contest,number].join(' ').upcase },
      },
      'special/high.jpg' => {
        'catchphrase' => {:font => 'lib/assets/League_Gothic.otf',:size => 80,:left => 250,:align => Magick::CenterAlign,:top => 300,:fill => 'white',:shadow => true,:text => 'IS TOO DAMN HIGH' },
        'message' => {:font => 'lib/assets/League_Gothic.otf',:size => 56,:left => 250,:align => Magick::CenterAlign,:top => 16,:chars => 30,:fill => 'white',:shadow => true,:text => text.gsub(/is too damn high/i,'').gsub(/too damn high/i,'') },
        'vote' => {:font => 'lib/assets/ONRAMP.ttf',:size => 50,:align => Magick::RightAlign,:left => 498,:top => 380,:stroke => 'white',:fill => flavor === 'no' ? 'red' : '#5a663e',:text => 'Vote '+flavor.capitalize },
        'measure' => {:font => 'lib/assets/ONRAMP.ttf',:size => 30,:align => Magick::RightAlign,:left => 496,:top => 420,:stroke => 'white',:fill => flavor === 'no' ? 'red' : '#5a663e',:text => [contest,number].join(' ').upcase },
      },
      'special/interesting.jpg' => {
        'catchphrase' => { :font => 'lib/assets/League_Gothic.otf',:size => 46, :left => 250,:align => Magick::CenterAlign,:top => 8,:fill => 'white',:shadow => false,:text => ('I don\'t always '+(text.split(/but when i do/i)[0].nil? ? '' : text.gsub(/I don\'t always/i,'').gsub(/I dont always/i,'').split(/but when i do/i)[0])+'but when I do').upcase(), :chars => 28, :stroke => '#333333',:strokeWidth => 1},
        'message' => {:font => 'lib/assets/League_Gothic.otf',:size => 50,:left => 250,:align => Magick::CenterAlign,:top => 280,:chars => 28,:fill => 'white',:stroke => '#333333',:strokeWidth => 1,:text => text.split(/but when i do/i)[1].nil? ? '' : text.split(/but when i do/i)[1].upcase()},
        'vote' => {:font => 'lib/assets/ONRAMP.ttf',:size => 50,:align => Magick::RightAlign,:left => 498,:top => 380,:stroke => 'white',:fill => flavor === 'no' ? 'red' : '#5a663e',:text => 'Vote '+flavor.capitalize},
        'measure' => {:font => 'lib/assets/ONRAMP.ttf',:size => 30,:align => Magick::RightAlign,:left => 496,:top => 420,:stroke => 'white',:fill => flavor === 'no' ? 'red' : '#5a663e',:text => [contest,number].join(' ').upcase,},
      }, 
      'special/boromir.jpg' => {
        'catchphrase' => {:font => 'lib/assets/League_Gothic.otf',:size => 80,:left => 250,:align => Magick::CenterAlign,:top => 8,:fill => 'white',:shadow => false,:text => ('one does not simply').upcase(),:chars => 28,:stroke => '#333333',:strokeWidth => 1},
        'message' => {:font => 'lib/assets/League_Gothic.otf',:size => 46,:left => 250,:align => Magick::CenterAlign,:top => 320,:chars => 28,:fill => 'white',:stroke => '#333333',:strokeWidth => 1,:text => text.gsub(/one does not simply/i,'').upcase()},
        'vote' => {:font => 'lib/assets/ONRAMP.ttf',:size => 70,:align => Magick::RightAlign,:left => 498,:top => 360,:stroke => 'white',:fill => flavor === 'no' ? 'red' : '#5a663e',:text => 'Vote '+flavor.capitalize},
        'measure' => {:font => 'lib/assets/ONRAMP.ttf',:size => 30,:align => Magick::RightAlign,:left => 496,:top => 416,:stroke => 'white',:fill => flavor === 'no' ? 'red' : '#5a663e',:text => [contest,number].join(' ').upcase, },
      },
      'special/morpheus.jpg' => {
        'catchphrase' => {:font => 'lib/assets/League_Gothic.otf',:size => 80,:left => 250,:align => Magick::CenterAlign,:top => 8,:fill => 'white',:shadow => false,:text => ('What if I told you').upcase(),:chars => 28,:stroke => '#333333',:strokeWidth => 1},
        'message' => {:font => 'lib/assets/League_Gothic.otf',:size => 40,:left => 164,:align => Magick::CenterAlign,:top => 330,:chars => 26,:fill => 'white',:stroke => '#333333',:strokeWidth => 1,:text => text.gsub(/What if I told you/i,'').upcase()},
        'vote' => {:font => 'lib/assets/ONRAMP.ttf',:size => 50,:align => Magick::RightAlign,:left => 498,:top => 370,:stroke => 'white',:fill => flavor === 'no' ? 'red' : '#5a663e',:text => 'Vote '+flavor.capitalize},
        'measure' => {:font => 'lib/assets/ONRAMP.ttf',:size => 30,:align => Magick::RightAlign,:left => 496,:top => 410,:stroke => 'white',:fill => flavor === 'no' ? 'red' : '#5a663e',:text => [contest,number].join(' ').upcase,},
      }
    }
    
    settings = themes[ theme ] || {}
    img = Magick::Image.read("app/assets/images/"+theme ).first

    settings.each do |title,section|

      weight = section[:weight] || Magick::NormalWeight
      fill = section[:fill] || 'white'
      stroke = section[:stroke] || 'transparent'
      strokeWidth = section[:strokeWidth] || 1
      shadow = section[:shadow]
      chars = section[:chars] || 1000
      align = section[:align] || Magick::LeftAlign
    
      msg = Magick::Draw.new
      msg.font_size( section[:size] ).font( section[:font] ).fill( fill ).font_weight( weight ).stroke( stroke ).stroke_width( strokeWidth ).text_align( align )

      if shadow
        shadow = Magick::Draw.new
        shadow.font_size( section[:size]  ).font( section[:font] ).fill('#747474').text_align( align )
      end

      text = section[:text].strip().gsub("''''","").gsub(/\n/,'')
    
      unless text.empty?
        row = 0
        until text.nil? do

          if text.length > chars
            line_end = text.rindex(' ',chars)
          else
            line_end = chars
          end

          line = text.slice(0,line_end).strip() || ''
          text = text.strip().slice(line_end,140)


          row += 1
          top = section[:size]*row+section[:top]

          msg.text( section[:left], top, line )

          if shadow
            shadow.text( section[:left]+1, top+2, line ) 
            shadow.draw img
          end
          msg.draw img
        end

      end
    end
    return img
  end
  

  def awsStart
    require 'aws/s3'
    
    AWS::S3::Base.establish_connection!( :access_key_id     =>  ENV['AWS3'], :secret_access_key => ENV['AWS3_SECRET'] ) unless AWS::S3::Base.connected?
    
    return AWS::S3::S3Object
    
  end
  
  def getTMP
    return 'tmp/memes-'+self.id.to_s+'.png'
    # aws = awsStart
    # aws.url_for( self.image, 'the-ballot', :expires_in => 10.seconds)
  end

  def saveMeme
    aws = awsStart
    filename = self.feedback_id.to_s+(Time.now.nsec/100000).to_s+'.png'
    aws.store( filename, self.makeMeme, 'the-ballot')
    self.image = filename
  end
  
  def destroy_meme
     # AWS::S3::S3Object.delete('myfile.png','the-ballot') 
  end

end
