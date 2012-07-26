
class MemeController < ApplicationController

  
  def make
    m = Meme.new( :quote => 'hey' )

    respond_to do |format|
      format.png { render :text =>  m.makeMeme }
      format.gif { render :text =>  anim.to_blob }
      format.all { render :text =>  request.env['HTTP_REFERER'] }
    end
  end
end