
class DrawController < ApplicationController
  def make
    require 'RMagick'


    # For storing the file
    # If we're storing the file
    # file_name = "tmp/done.png"
    # file_path = file_name
    # File.delete file_path if File.exists? file_path
    
    msg = Magick::Draw.new
    msg.font_size(24).font('lib/assets/gothic.ttf').fill('white')
    
    if params[:format] == 'png'
      img = Magick::Image.read("lib/assets/done.png").first
      thumb = img.scale(0.25)
      
      msg.text(50, 160, params[:message])
      msg.draw thumb

      # For storing the file
      #@path = file_name
      #thumb.write file_path


    else

      anim = Magick::ImageList.new

      files = Dir["lib/assets/portraits/*.jpg"]

      files.each do |file|
        frame =  Magick::ImageList.new(file)
        frame.scale!(200,100)
        anim.new_image(200, 100) { self.format = 'gif'; self.background_color = 'red' }
        anim.last.composite!( frame,0,0, Magick::OverCompositeOp)

        msg.text(30, 100, params[:message])
        msg.draw anim.last
      end

      anim.delay = 5
  end

    respond_to do |format|
      format.png { render :text =>  thumb.to_blob }
      format.gif { render :text =>  anim.to_blob }
      #format.png { render :text => open(@path, "rb").read }
    end
  end
end