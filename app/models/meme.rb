class Meme < ActiveRecord::Base
  attr_accessible :image, :quote, :feedback, :theme
  
  belongs_to :feedback
  has_one :user, :through => :feedback
  has_one :option, :through => :feedback

  
  before_save :saveMeme
  before_destroy :destroyMeme
  
  def makeMeme 
    require 'RMagick'


    size = 52
    row = 0
    text = self.quote || ' '
    text = text.slice(0,140)

    msg = Magick::Draw.new
    msg.font_size(size).font('lib/assets/gothic.ttf').fill('white').text_align(Magick::RightAlign)
    shadow = Magick::Draw.new
    shadow.font_size(size).font('lib/assets/gothic.ttf').fill('#747474').text_align(Magick::RightAlign)

    img = Magick::Image.read("lib/assets/share/1.jpg").first


    until text.nil? do

      if text.length > 30
        line_end = text.rindex(' ',30)
      else
        line_end = 30
      end

      line = text.slice(0,line_end)
      text = text.strip().slice(line_end,140)


      row += 1
      top = size*row+10

      msg.text(480, top, line )
      shadow.text(480+1, top+2, line )
      shadow.draw img
      msg.draw img

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
    # AWS::S3::S3Object.store('myfile.png', open('https://a248.e.akamai.net/assets.github.com/images/modules/about_page/octocat.png?1315937721'), 'the-ballot')
    # self.image = AWS::S3::S3Object.url_for('myfile.png','the-ballot')
  end
  
  def destroy_meme
     # AWS::S3::S3Object.delete('myfile.png','the-ballot') 
  end

end
