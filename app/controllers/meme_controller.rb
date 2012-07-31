class MemeController < ApplicationController

  def new
    feedback = Feedback.find( params[:id] )

    if current_user != feedback.user
      render :json => 'You no can meme someone else\'s comment'
    
    else
      @meme = feedback.memes.new
      
      if params[:frame]
        render :layout => false, :template => 'meme/_form.html.erb'
      else
        render :layout => false
      end
    end
    
  end
  
  def create
  end
  
  def show
    feedback = Feedback.find( params[:id] )
    m = feedback.memes.new( :quote => params[:quote], :theme => params[:theme] )

    respond_to do |format|
      format.all { render :text =>  Base64.encode64( m.makeMeme ) }
    end
  end
end