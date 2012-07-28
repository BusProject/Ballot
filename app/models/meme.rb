class Meme < ActiveRecord::Base
  attr_accessible :image, :quote, :feedback, :theme
  
  belongs_to :feedback
  has_one :user, :through => :feedback
  has_one :option, :through => :feedback

  
  before_save :saveMeme
  before_destroy :destroyMeme
  
  def makeMeme 
    require 'RMagick'


    text = self.quote || ' '
    theme = self.theme || 'yes/1.jpg'
    theme = theme.gsub('/assets/','')
    text.slice(0,140)
    flavor = ['no','against','opposed'].index( self.option.name.downcase ) ? 'no' : 'yes'
    
    themes = {
      'yes/1.jpg' => { 
        'quote' => {
          :font => 'lib/assets/Museo_Slab_500.otf',
          :size => 38,
          :align => Magick::CenterAlign,
          :left => 250,
          :shadow => true,
          :top => 10+( ( text.length/28 > 3 ? 0 : 3 - text.length/28 ) )*38,
          :chars => 28,
          :text => "''"+text+"''",
        },
        'name' => {
          :font => 'lib/assets/Museo_Slab_500.otf',
          :size => 20,
          :align => Magick::RightAlign,
          :left => 480,
          :shadow => true,
          :top => 280,
          :text => '- '+self.user.first_name+' '+self.user.last_name,
        },
        'measure' => {
          :font => 'lib/assets/League_Gothic.otf',
          :size => 44,
          :left => 40,
          :top => 444,
          :text => ('On Measure '+self.option.choice.contest.gsub('Measure','').strip() ).upcase(),
          :fill => 'transparent',
          :stroke => 'white',
          :weight => Magick::NormalWeight
        },
      },
      'yes/2.jpg' => {
        'quote' => {
          :font => 'lib/assets/Haymaker.ttf',
          :size => 20,
          :align => Magick::CenterAlign,
          :left => 250,
          :top => 284+( ( text.length/32 > 2 ? 0 : 2 - text.length/32 ) )*20,
          :chars => 32,
          :text => "''"+text+"''",
          :fill => 'black'
        },
        'name' => {
          :font => 'lib/assets/Wisdom_Script.otf',
          :size => 20,
          :align => Magick::CenterAlign,
          :left => 250,
          :top => 400,
          :text => '- '+self.user.first_name+' '+self.user.last_name,
          :fill => 'black'
        },
        'measure' => {
          :font => 'lib/assets/Wisdom_Script.otf',
          :size => 36,
          :left => 250,
          :top => 120,
          :text => 'On Measure',
          :fill => 'black',
          :align => Magick::CenterAlign,
        },
        'numba' => {
          :font => 'lib/assets/Haymaker.ttf',
          :size => 80,
          :left => 244,
          :top => 150,
          :text => self.option.choice.contest.gsub('Measure','').strip().upcase(),
          :fill => 'black',
          :align => Magick::CenterAlign,
        }
      },
      'yes/3.jpg' => {
        'quote' => {
          :font => 'lib/assets/ONRAMP.ttf',
          :size => 44,
          :left => 20,
          :top => 120+( ( text.length/28 > 2.5 ? 0 : 2.5 - text.length/28 ) )*44,
          :chars => 28,
          :text => "''"+text+"''",
          :fill => '#5a663e'
        },
        'name' => {
          :font => 'lib/assets/Museo_Slab_500italic.otf',
          :size => 20,
          :left => 20,
          :top => 410,
          :text => self.user.first_name+' '+self.user.last_name,
          :fill => '#5a663e'
        },
        'measure' => {
          :font => 'lib/assets/ONRAMP.ttf',
          :size => 50,
          :left => 24,
          :top => 68,
          :text => ('On Measure '+self.option.choice.contest.gsub('Measure','').strip() ).upcase(),
          :fill => '#d37a3c',
        }
      },
      'yes/4.jpg' => {
        'quote' => {
          :font => 'lib/assets/Museo_Slab_500.otf',
          :size => 30,
          :left => 16,
          :shadow => true,
          :top => 200+( ( text.length/28 > 2 ? 0 : 2 - text.length/28 ) )*38,
          :chars => 28,
          :text => "''"+text+"''"
        },
        'name' => {
          :font => 'lib/assets/Museo_Slab_500italic.otf',
          :size => 20,
          :left => 16,
          :top => 390,
          :text => self.user.first_name+' '+self.user.last_name,
          :fill => 'white',
          :shadow => true
        },
        'on' => {
          :font => 'lib/assets/Museo_Slab_500.otf',
          :size => 28,
          :left => 310,
          :top => 40,
          :text => 'on measure',
          :fill => 'white',
          :shadow => true
        },
        'measure' => {
          :font => 'lib/assets/Museo_Slab_500.otf',
          :size => 28,
          :left => 310,
          :top => 70,
          :text => self.option.choice.contest.gsub('Measure','').strip().upcase(),
          :fill => 'white',
          :shadow => true
        },
        'this' => {
          :font => 'lib/assets/Museo_Slab_500.otf',
          :size => 28,
          :left => 310,
          :top => 100,
          :text => 'this election',
          :fill => 'white',
          :shadow => true
        }
      },
      'no/1.jpg' => { 
        'quote' => {
          :font => 'lib/assets/Museo_Slab_500.otf',
          :size => 38,
          :align => Magick::CenterAlign,
          :left => 250,
          :shadow => true,
          :top => 10+( ( text.length/28 > 3 ? 0 : 3 - text.length/28 ) )*38,
          :chars => 28,
          :text => "''"+text+"''",
        },
        'name' => {
          :font => 'lib/assets/Museo_Slab_500.otf',
          :size => 20,
          :align => Magick::RightAlign,
          :left => 480,
          :shadow => true,
          :top => 280,
          :text => '- '+self.user.first_name+' '+self.user.last_name,
        },
        'measure' => {
          :font => 'lib/assets/League_Gothic.otf',
          :size => 44,
          :left => 40,
          :top => 444,
          :text => ('On Measure '+self.option.choice.contest.gsub('Measure','').strip() ).upcase(),
          :fill => 'transparent',
          :stroke => 'white',
          :weight => Magick::NormalWeight
        },
      },
      'no/2.jpg' => {
        'quote' => {
          :font => 'lib/assets/Haymaker.ttf',
          :size => 20,
          :align => Magick::CenterAlign,
          :left => 250,
          :top => 284+( ( text.length/32 > 2 ? 0 : 2 - text.length/32 ) )*20,
          :chars => 32,
          :text => "''"+text+"''",
          :fill => 'black'
        },
        'name' => {
          :font => 'lib/assets/Wisdom_Script.otf',
          :size => 20,
          :align => Magick::CenterAlign,
          :left => 250,
          :top => 400,
          :text => '- '+self.user.first_name+' '+self.user.last_name,
          :fill => 'black'
        },
        'measure' => {
          :font => 'lib/assets/Wisdom_Script.otf',
          :size => 36,
          :left => 250,
          :top => 120,
          :text => 'On Measure',
          :fill => 'black',
          :align => Magick::CenterAlign,
        },
        'numba' => {
          :font => 'lib/assets/Haymaker.ttf',
          :size => 80,
          :left => 244,
          :top => 150,
          :text => self.option.choice.contest.gsub('Measure','').strip().upcase(),
          :fill => 'black',
          :align => Magick::CenterAlign,
        }
      },
      'no/3.jpg' => {
        'quote' => {
          :font => 'lib/assets/ONRAMP.ttf',
          :size => 44,
          :left => 20,
          :top => 120+( ( text.length/28 > 2.5 ? 0 : 2.5 - text.length/28 ) )*44,
          :chars => 28,
          :text => "''"+text+"''",
          :fill => '#ffbabc'
        },
        'name' => {
          :font => 'lib/assets/Museo_Slab_500italic.otf',
          :size => 20,
          :left => 20,
          :top => 410,
          :text => self.user.first_name+' '+self.user.last_name,
          :fill => '#ffbabc'
        },
        'measure' => {
          :font => 'lib/assets/ONRAMP.ttf',
          :size => 50,
          :left => 24,
          :top => 68,
          :text => ('On Measure '+self.option.choice.contest.gsub('Measure','').strip() ).upcase(),
          :fill => 'white',
        }
      },
      'no/4.jpg' => {
        'quote' => {
          :font => 'lib/assets/Museo_Slab_500.otf',
          :size => 30,
          :left => 16,
          :shadow => true,
          :top => 200+( ( text.length/28 > 2 ? 0 : 2 - text.length/28 ) )*38,
          :chars => 28,
          :text => "''"+text+"''"
        },
        'name' => {
          :font => 'lib/assets/Museo_Slab_500italic.otf',
          :size => 20,
          :left => 16,
          :top => 390,
          :text => self.user.first_name+' '+self.user.last_name,
          :fill => 'white',
          :shadow => true
        },
        'on' => {
          :font => 'lib/assets/Museo_Slab_500.otf',
          :size => 28,
          :left => 310,
          :top => 40,
          :text => 'on measure',
          :fill => 'white',
          :shadow => true
        },
        'measure' => {
          :font => 'lib/assets/Museo_Slab_500.otf',
          :size => 28,
          :left => 310,
          :top => 70,
          :text => self.option.choice.contest.gsub('Measure','').strip().upcase(),
          :fill => 'white',
          :shadow => true
        },
        'this' => {
          :font => 'lib/assets/Museo_Slab_500.otf',
          :size => 28,
          :left => 310,
          :top => 100,
          :text => 'this election',
          :fill => 'white',
          :shadow => true
        }
      },
      'special/gosling.jpg' => {
        'hey girl' => {
          :font => 'lib/assets/League_Gothic.otf',
          :size => 80,
          :left => 20,
          :top => 10,
          :fill => 'black',
          :text => 'Hey Girl'
        },
        'message' => {
          :font => 'lib/assets/League_Gothic.otf',
          :size => 40,
          :left => 20,
          :top => 120,
          :chars => 17,
          :fill => 'black',
          :text => text.gsub(/hey girl/i,'')
        },
        'vote' => {
          :font => 'lib/assets/ONRAMP.ttf',
          :size => 50,
          :align => Magick::RightAlign,
          :left => 498,
          :top => 380,
          :fill => flavor === 'no' ? 'red' : '#5a663e',
          :text => 'Vote '+flavor.capitalize
        },
        'measure' => {
          :font => 'lib/assets/ONRAMP.ttf',
          :size => 30,
          :align => Magick::RightAlign,
          :left => 496,
          :top => 420,
          :fill => flavor === 'no' ? 'red' : '#5a663e',
          :text => ('Measure '+self.option.choice.contest.gsub('Measure','').strip() ).upcase(),
        },
      },
      'special/high.jpg' => {
        'hey girl' => {
          :font => 'lib/assets/League_Gothic.otf',
          :size => 74,
          :left => 250,
          :align => Magick::CenterAlign,
          :top => 300,
          :fill => 'white',
          :shadow => true,
          :text => 'IS TOO DAMN HIGH'
        },
        'message' => {
          :font => 'lib/assets/League_Gothic.otf',
          :size => 60,
          :left => 250,
          :align => Magick::CenterAlign,
          :top => 20,
          :chars => 18,
          :fill => 'white',
          :shadow => true,
          :text => text.gsub(/is too damn high/i,'').gsub(/too damn high/i,'')
        },
        'vote' => {
          :font => 'lib/assets/ONRAMP.ttf',
          :size => 50,
          :align => Magick::RightAlign,
          :left => 498,
          :top => 380,
          :stroke => 'white',
          :fill => flavor === 'no' ? 'red' : '#5a663e',
          :text => 'Vote '+flavor.capitalize
        },
        'measure' => {
          :font => 'lib/assets/ONRAMP.ttf',
          :size => 30,
          :align => Magick::RightAlign,
          :left => 496,
          :top => 420,
          :stroke => 'white',
          :fill => flavor === 'no' ? 'red' : '#5a663e',
          :text => ('Measure '+self.option.choice.contest.gsub('Measure','').strip() ).upcase(),
        },
      }
    }


    settings = themes[ theme ] || {}
    img = Magick::Image.read("app/assets/images/"+theme ).first

    settings.each do |title,section|

      weight = section[:weight] || Magick::NormalWeight
      fill = section[:fill] || 'white'
      stroke = section[:stroke] || 'transparent'
      shadow = section[:shadow]
      chars = section[:chars] || 1000
      align = section[:align] || Magick::LeftAlign
      
      msg = Magick::Draw.new
      msg.font_size( section[:size] ).font( section[:font] ).fill( fill ).font_weight( weight ).stroke( stroke ).text_align( align )

      if shadow
        shadow = Magick::Draw.new
        shadow.font_size( section[:size]  ).font( section[:font] ).fill('#747474').text_align( align )
      end

      text = section[:text].strip().gsub("''''","")
      
      unless text.empty?
        row = 0
        until text.nil? do

          if text.length > chars
            line_end = text.rindex(' ',chars)
          else
            line_end = chars
          end

          line = text.slice(0,line_end).strip()
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
    






    return img.to_blob

  #     HOW TO MAKE ANIMATED GIFS
  #     anim = Magick::ImageList.new
  # 
  #     files = Dir["lib/assets/portraits/*.jpg"]
  # 
  #     files.each do |file|
  #       frame =  Magick::ImageList.new(file)
  #       frame.scale!(200,100)
  #       anim.new_image(200, 100) { self.format = 'gif'; self.background_color = 'red' }
  #       anim.last.composite!( frame,0,0, Magick::OverCompositeOp)
  #       msg.text(30, 100, text )
  #       msg.draw anim.last
  #     end
  #     anim.delay = 5

  end
  
  def save_meme
    require 'aws/s3'
    
    # AWS::S3::S3Object.store('myfile.png', open('https://a248.e.akamai.net/assets.github.com/images/modules/about_page/octocat.png?1315937721'), 'the-ballot')
    # self.image = AWS::S3::S3Object.url_for('myfile.png','the-ballot')
  end
  
  def destroy_meme
     # AWS::S3::S3Object.delete('myfile.png','the-ballot') 
  end

end
