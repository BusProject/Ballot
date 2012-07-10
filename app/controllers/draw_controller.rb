
class DrawController < ApplicationController
  def make
    require 'RMagick'


    # For storing the file
    # If we're storing the file
    # file_name = "tmp/done.png"
    # file_path = file_name
    # File.delete file_path if File.exists? file_path
    
    if params[:message] == 'png'
      img = Magick::Image.read("Done.png").first
      thumb = img.scale(0.25)
    
      msg = Magick::Draw.new
      msg.font_size(24).font('gothic.ttf').fill('white')
      msg.text(60, 35, params[:message])
      msg.draw thumb

      # For storing the file
      #@path = file_name
      #thumb.write file_path


    else


      anim = Magick::ImageList.new
      anim.read("lib/assets/portraits/busfed-portraits-bygarrettdownen-03958.jpg")
      # anim1 =  Magick::ImageList.new("lib/assets/portraits/busfed-portraits-bygarrettdownen-03958.jpg")
      anim.read("lib/assets/portraits/busfed-portraits-bygarrettdownen-03960.jpg")
      # anim2 = Magick::ImageList.new("lib/assets/portraits/busfed-portraits-bygarrettdownen-03960.jpg")
      
      # anim = anim1.composite_layers(anim2)
      anim.delay = 10
      anim.format = 'gif'
      anim.iterations = 0
      anim.montage
      
      anim.optimize_layers(Magick::CoalesceLayer)


      

  end


    respond_to do |format|
      format.png { render :text =>  thumb.to_blob }
      format.gif { render :text =>  anim.to_blob }
      #format.png { render :text => open(@path, "rb").read }
    end
  end
end