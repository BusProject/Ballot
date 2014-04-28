class Meme < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  attr_accessible :image, :quote, :feedback, :theme

  belongs_to :feedback
  has_one :user, :through => :feedback
  has_one :option, :through => :feedback




  def shareText
    return ['"'+self.quote+'" - ',self.user.name,self.user.to_url(true)].join(' ')
  end

  def fbMeme user = self.user, page

    if !page
      me = FbGraph::User.me( user.fb )
    else
      me = FbGraph::Page.new( user.fb, :access_token => user.authentication_token ).fetch
    end

    message = self.shareText

    photo = me.photo!( :source => self.makeFile, :message => message, :access_token => user.authentication_token )


    self.fb = 'https://www.facebook.com/photo.php?fbid='+photo.identifier
    self.save if user == self.user

    return self.fb
  end

  def makeBlob reset = false
    require 'RMagick'
    if self.new_record? || !File.exists?( self.getTMP ) || reset
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
    theme = self.theme || 'new/1.jpg'
    theme = theme.gsub('/assets/','')
    name = self.option.name
    action = self.option.type

    text.slice(0,140)

    if self.option.choice.contest_type.downcase.index('ballot').nil?
      type = 'Candidate'
      contest = self.option.name
      action = 'Vote For'
      flavor = 'yes'
    else
      action = 'Vote '+self.option.type
      contest = self.option.choice.contest
      type = 'Ballot'
      flavor = self.option.type
    end

    comment = text.length > 0 ? 'Comment' : ''


    themes = {
      'newBallotComment' => {
        'action' => {:font => 'lib/assets/League_Gothic.otf',:size => 180,:left => 250,:align => Magick::CenterAlign,:top => -20,:fill => 'white',:shadow => true,:text => action.upcase },
        'on' => {:font => 'lib/assets/Mission-Script.otf',:size => 40,:left => 40,:align => Magick::LeftAlign, :top => 180,:fill => 'white',:shadow => true,:text => 'on' },
        'measure' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 46,:left => 80,:align => Magick::LeftAlign,:top => 180,:fill => 'white',:shadow => true,:text => contest },
        'comment' => {:font => 'lib/assets/OpenSans-Bold.ttf',:size => 28,:left => 250,:align => Magick::CenterAlign,:top => 264,:fill => 'white',:shadow => true,:text => text, :chars => 28 },
        'name' => {:font => 'lib/assets/League_Gothic.otf',:size => 20,:left => 200,:align => Magick::LeftAlign,:top => 454,:fill => 'white',:shadow => false,:text => '- created by '+self.user.name+' on the ballot.org' }
      },
      'newBallot' => {
        'action' => {:font => 'lib/assets/League_Gothic.otf',:size => 180,:left => 250,:align => Magick::CenterAlign,:top => -20,:fill => 'white',:shadow => true,:text => action.upcase },
        'on' => {:font => 'lib/assets/Mission-Script.otf',:size => 40,:left => 40,:align => Magick::LeftAlign, :top => 220,:fill => 'white',:shadow => true,:text => 'on' },
        'measure' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 46,:left => 80,:align => Magick::LeftAlign,:top => 220,:fill => 'white',:shadow => true,:text => contest },
        'november' => {:font => 'lib/assets/League_Gothic.otf',:size => 90,:left => 250,:align => Magick::CenterAlign,:top => 300,:fill => 'white',:shadow => true,:text => 'on November 6th'.upcase },
        'name' => {:font => 'lib/assets/League_Gothic.otf',:size => 20,:left => 200,:align => Magick::LeftAlign,:top => 454,:fill => 'white',:shadow => false,:text => '- created by '+self.user.name+' on the ballot.org' }
      },
      'newCandidateComment' => {
        'action' => {:font => 'lib/assets/League_Gothic.otf',:size => 160,:left => 250,:align => Magick::CenterAlign,:top => -30,:fill => 'white',:shadow => true,:text =>  action.upcase },
        'candidate' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 50,:left => 250,:align => Magick::CenterAlign,:top => 150,:fill => 'white',:shadow => true,:text => name },
        'office' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 26, :chars => 28,:left => 250,:align => Magick::CenterAlign,:top => 210,:fill => 'white',:shadow => true,:text => 'for '+ self.option.choice.contest },
        'comment' => {:font => 'lib/assets/OpenSans-Bold.ttf',:size => 28,:left => 250,:align => Magick::CenterAlign,:top => 304,:fill => 'white',:shadow => true,:text => text, :chars => 32 },
        'name' => {:font => 'lib/assets/League_Gothic.otf',:size => 20,:left => 200,:align => Magick::LeftAlign,:top => 454,:fill => 'white',:shadow => false,:text => '- created by '+self.user.name+' on the ballot.org' }
      },
      'newCandidate' => {
        'action' => {:font => 'lib/assets/League_Gothic.otf',:size => 180,:left => 250,:align => Magick::CenterAlign,:top => -20,:fill => 'white',:shadow => true,:text => action.upcase },
        'candidate' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 50,:left => 250,:align => Magick::CenterAlign,:top => 190,:fill => 'white',:shadow => true,:text => name },
        'office' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 26, :chars => 30,:left => 250,:align => Magick::CenterAlign,:top => 250,:fill => 'white',:shadow => true,:text => 'for '+ self.option.choice.contest },
        'november' => {:font => 'lib/assets/League_Gothic.otf',:size => 90,:left => 250,:align => Magick::CenterAlign,:top => 320,:fill => 'white',:shadow => true,:text => 'on November 6th'.upcase },
        'name' => {:font => 'lib/assets/League_Gothic.otf',:size => 20,:left => 200,:align => Magick::LeftAlign,:top => 454,:fill => 'white',:shadow => false,:text => '- created by '+self.user.name+' on the ballot.org' }
      },
      'special/gosling.jpg' => {
        'hey girl' => {:font => 'lib/assets/League_Gothic.otf',:size => 80,:left => 20,:top => 10,:fill => 'black',:text => 'Hey Girl' },
        'message' => {:font => 'lib/assets/League_Gothic.otf',:size => 40,:left => 20,:top => 120,:chars => 17,:fill => 'black',:text => text.gsub(/hey girl/i,'') },
        'vote' => {:font => 'lib/assets/Mission-Script.otf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 380, :fill => 'black', :text => action.upcase },
        'measure' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 410, :fill => 'black', :text => contest.upcase },
      },
      'special/high.jpg' => {
        'catchphrase' => {:font => 'lib/assets/League_Gothic.otf',:size => 80,:left => 250,:align => Magick::CenterAlign,:top => 280,:fill => 'white',:shadow => true,:text => 'IS TOO DAMN HIGH' },
        'message' => {:font => 'lib/assets/League_Gothic.otf',:size => 30,:left => 250,:align => Magick::CenterAlign,:top => 16,:chars => 50,:fill => 'white',:shadow => true,:text => text.gsub(/is too damn high/i,'').gsub(/too damn high/i,'') },
        'vote' => {:font => 'lib/assets/Mission-Script.otf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 380, :fill => 'white',:shadow => true, :text => action.upcase },
        'measure' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 410, :fill => 'white',:shadow => true, :text => contest.upcase },
      },
      'special/interesting.jpg' => {
        'catchphrase' => { :font => 'lib/assets/League_Gothic.otf',:size => 46, :left => 250,:align => Magick::CenterAlign,:top => 8,:fill => 'white',:shadow => true,:text => ('I don\'t always '+(text.split(/but when i do/i)[0].nil? ? '' : text.gsub(/I don\'t always/i,'').gsub(/I dont always/i,'').split(/but when i do/i)[0])+'but when I do').upcase(), :chars => 28 },
        'message' => {:font => 'lib/assets/League_Gothic.otf',:size => 30,:left => 20,:align => Magick::LeftAlign,:shadow => true, :top => 290,:chars => 28,:fill => 'white',:text => text.split(/but when i do/i)[1].nil? ? '' : text.split(/but when i do/i)[1].upcase()},
        'vote' => {:font => 'lib/assets/Mission-Script.otf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 380, :fill => 'white',:shadow => true, :text => action.upcase },
        'measure' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 410, :fill => 'white',:shadow => true, :text => contest.upcase },
      },
      'special/boromir.jpg' => {
        'catchphrase' => {:font => 'lib/assets/League_Gothic.otf',:size => 80,:left => 250,:align => Magick::CenterAlign,:top => 8,:fill => 'white',:shadow => true,:text => ('one does not simply').upcase(),:chars => 28 },
        'message' => {:font => 'lib/assets/League_Gothic.otf',:size => 40,:left => 20, :shadow => true,:align => Magick::LeftAlign,:top => 320,:chars => 28,:fill => 'white',:text => text.gsub(/one does not simply/i,'').upcase()},
        'vote' => {:font => 'lib/assets/Mission-Script.otf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 380, :fill => 'white',:shadow => true, :text => action.upcase },
        'measure' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 410, :fill => 'white',:shadow => true, :text => contest.upcase },
      },
      'special/morpheus.jpg' => {
        'catchphrase' => {:font => 'lib/assets/League_Gothic.otf',:size => 80,:left => 250,:align => Magick::CenterAlign,:top => 8,:fill => 'white',:shadow => true,:text => ('what if i told you').upcase() ,:chars => 28 },
        'message' => {:font => 'lib/assets/League_Gothic.otf',:size => 30,:left => 20,:align => Magick::LeftAlign,:top => 330,:chars => 26,:fill => 'white',:shadow => true,:text => text.gsub(/what if i told you/i,'').upcase()},
        'vote' => {:font => 'lib/assets/Mission-Script.otf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 380, :fill => 'white',:shadow => true, :text => action.upcase },
        'measure' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 410, :fill => 'white',:shadow => true, :text => contest.upcase },
      },
      'special/coach-taylor.jpg' => {
        'catchphrase' => {:font => 'lib/assets/League_Gothic.otf',:size => 110,:left => 210,:align => Magick::LeftAlign,:top => -30,:fill => 'white',:shadow => true,:text => 'Listen up',:chars => 28,:strokeWidth => 1},
        'message' => {:font => 'lib/assets/League_Gothic.otf',:size => 30,:left => 20,:align => Magick::LeftAlign,:top => 260,:chars => 26,:fill => 'white',:shadow => true, :text => text.gsub(/listen up/i,'')},
        'vote' => {:font => 'lib/assets/Mission-Script.otf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 390, :fill => 'white',:shadow => true, :text => action.upcase },
        'measure' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 420, :fill => 'white',:shadow => true, :text => contest.upcase },
      },
      'special/walter.jpg' => {
        'catchphrase' => {:font => 'lib/assets/League_Gothic.otf',:size => 50,:left => 250,:align => Magick::CenterAlign,:top => 0,:fill => 'white',:shadow => true,:text => 'AM I THE ONLY ONE AROUND HERE',:chars => 32,:strokeWidth => 1},
        'message' => {:font => 'lib/assets/League_Gothic.otf',:size => 40,:left => 250,:align => Magick::CenterAlign,:top => 290,:chars => 34,:fill => 'white',:shadow => true, :text => text.gsub(/am i the only one around here/i,'')},
        'vote' => {:font => 'lib/assets/Mission-Script.otf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 380, :fill => 'white',:shadow => true, :text => action.upcase },
        'measure' => {:font => 'lib/assets/Arvo-bold.ttf',:size => 30,:align => Magick::RightAlign,:left => 490,:top => 410, :fill => 'white',:shadow => true, :text => contest.upcase },
      }
    }

    comment = text.length > 0 ? 'Comment' : ''

    settings = themes[ theme.index('new').nil? ? theme : 'new'+type+comment ] || {}

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
        shadow.font_size( section[:size]  ).font( section[:font] ).fill('#333').text_align( align )
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
          top = section[:size]*row*1.1+section[:top]

          msg.text( section[:left], top, line ) unless line.empty? || line.nil?

          if shadow
            shadow.text( section[:left]-2, top+3, line )   unless line.empty? || line.nil?
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
