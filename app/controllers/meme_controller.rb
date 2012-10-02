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
  
  def update
    if params[:meme] != 'null'
      m = Meme.find(params[:meme])
      m[:quote] = params[:quote]
      m[:theme] = params[:theme]
    else
      feedback = Feedback.find( params[:id] )
      m = feedback.memes.new( :quote => params[:quote], :theme => params[:theme] )
    end

    if m.user.id == current_user.id
      if m.save
        render :json => { :success => true, :url => meme_show_image_path( m.id )+'.png', :id => m.id }
      else
        render :json => { :success => false }
      end

    else
      render :json => { :success => false, :message => 'You cannot do that' } 
    end

  end
  
  def preview
    if params[:meme] != 'null'
      m = Meme.find(params[:meme])
      m[:quote] = params[:quote]
      m[:theme] = params[:theme]
      m.save
    else
      feedback = Feedback.find( params[:id] )
      m = feedback.memes.new( :quote => params[:quote], :theme => params[:theme] )
    end

    respond_to do |format|
      format.all { render :text =>  Base64.encode64( m.makeBlob ( true ) ) }
    end
  end
  
  def show
    @meme = Meme.find_by_id( params[:id] )

    raise ActionController::RoutingError.new('Could not find that meme') if @meme.nil? 

    @image = ENV['BASE']+meme_show_image_path(@meme.id)+'.png'
    @message = @meme.quote
    @title = @meme.user.guide_name.nil? || @meme.user.guide_name.empty? ? @meme.option.name+' on '+@meme.option.choice.contest : @meme.user.guide_name
    
    respond_to do |format|
      format.png { render :text =>  @meme.makeBlob }
      format.jpeg { render :text =>  @meme.makeBlob }
      format.gif { render :text =>  @meme.makeBlob }
      format.html { render :layout => false, :template => 'meme/_img.html.erb' }
    end
  end

  def destroy
    m = Meme.find_by_id(params[:id])
    
    raise ActionController::RoutingError.new('Could not find that meme') if m.nil? 
    
    if m.user.id == current_user.id
      m.delete
      render :json => { :success => true, :message => 'Meme deleted' } 
    else
      render :json => { :success => false, :message => 'You cannot do that' } 
    end
  end
  
  def fb
    m = Meme.find(params[:id])
    page = false
    
    # Refreashing Auth tokens
    if session[:logged_in_as] && user = User.find(session[:logged_in_as]) && session[:logged_in_as] != current_user.id
      user = User.find(session[:logged_in_as])
      json = JSON::parse(RestClient.get 'https://graph.facebook.com/me/accounts?access_token='+user.authentication_token)
      token = json['data'].select{ |p| p['id'] == current_user.fb }.first['access_token']
      page = true # If we've got another user logged in - we know it's a page
    else
      newToken = RestClient.get 'https://graph.facebook.com/oauth/access_token?client_id='+ENV['FACEBOOK']+'&client_secret='+ENV['FACEBOOK_SECRET']+'&grant_type=fb_exchange_token&fb_exchange_token='+current_user.authentication_token
      token = newToken.split('&')[0].gsub('access_token=','') # Refreshes the current token
    end

    current_user.update_attributes( :authentication_token => token ) # Refreshes the current token
    
    
    if m.fb.nil? || m.user == current_user
      go = m.fbMeme( current_user, page )
    else
      permission = RestClient.get 'https://graph.facebook.com/'+m.fb+'?acess_token='+current_user.authentication_token # Seeing if the user can see the photo
   
      unless permission == 'false'
        go = 'http://facebook.com/sharer/sharer.php?u='+m.fb 
      else
        go = m.fbMeme current_user
      end
   
    end
   
   redirect_to go

  end


end