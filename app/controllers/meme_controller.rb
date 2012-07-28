class MemeController < ApplicationController

  def new
    @meme = Feedback.find( params[:id] ).memes.new
    respond_to do |format|
      # format.all {render :layout => false}
      format.html {render :layout => false, :template => 'meme/_form.html.erb'}
    end
    
  end
  
  def create
  end
  
  def show
    feedback = Feedback.find( params[:id] )
    m = feedback.memes.new( :quote => params[:quote], :theme => params[:theme] )

    respond_to do |format|
      format.all { render :text =>  ActiveSupport::Base64.encode64( m.makeMeme ) }
    end
  end
end