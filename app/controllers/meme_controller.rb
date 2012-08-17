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
      format.all { render :text =>  Base64.encode64( m.makeMeme ) }
    end
  end
  
  def show
    @meme = Meme.find( params[:id] )
    respond_to do |format|
      format.png { render :text =>  @meme.makeMeme }
      format.jpeg { render :text =>  @meme.makeMeme }
      format.gif { render :text =>  @meme.makeMeme }
      format.html { render :layout => false, :template => 'meme/_img.html.erb' }
    end
  end

  def destroy
    m = Meme.find(params[:id])
    
    if m.user.id == current_user.id
      m.delete
      render :json => { :success => true, :message => 'Meme deleted' } 
    else
      render :json => { :success => false, :message => 'You cannot do that' } 
    end
  end
  
  def fb
    m = Meme.find(params[:id])
    
    if m.fb.nil?
      go = m.fbMeme current_user
    else
      permission = RestClient.get 'https://graph.facebook.com/'+m.fb+'?acess_token='+current_user.authentication_token # Seeing if the user can see the photo

      unless permission == 'false'
        go = 'http://facebook.com/sharer/sharer.php?u='+m.fb 
      else
        go = m.fbMeme current_user
      end

    end

    render :json => go
#    redirect_to go

  end


end