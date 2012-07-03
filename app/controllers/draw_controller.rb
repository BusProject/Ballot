
class DrawController < ApplicationController
  def make
    require 'RMagick'


    file_name = "tmp/done.png"
    file_path = file_name

    File.delete file_path if File.exists? file_path
    img = Magick::Image.read("Done.png").first
    thumb = img.scale(0.25)
    
    msg = Magick::Draw.new
    msg.font_size(24).font('gothic.ttf').fill('blue')
    msg.text(60, 35, params[:message])
    msg.draw thumb
    
    @path = file_name

    thumb.write file_path

    respond_to do |format|
      format.png { render :text =>  thumb.to_blob }
      #format.png { render :text => open(@path, "rb").read }
    end
  end
end