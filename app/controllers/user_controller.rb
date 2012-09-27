class UserController < ApplicationController
  before_filter :check_user

  def update
    logger.debug ' running update'
    user = current_user

    user.description = params[:description] unless params[:description] != 'null' && params[:description].nil?
    user.guide_name = params[:guide_name] unless params[:guide_name] != 'null' && params[:guide_name].nil?
    user.profile = params[:profile].downcase.gsub(' ','_').gsub('/','').gsub('?','').gsub('#','').gsub('&','') unless params[:profile] != 'null' && params[:profile].nil?
    user.primary = params[:primary] unless params[:primary] != 'null' && params[:primary].nil?
    user.secondary = params[:secondary] unless params[:secondary] != 'null' && params[:secondary].nil?
    user.bg = params[:bg] unless params[:bg] != 'null' && params[:bg].nil?
    user.header = params[:user][:header] if !params[:user].nil? && !params[:user][:header].nil?
    
    user.fb_friends = params[:fb_friends] unless params[:fb_friends].nil?

    
    if params[:clearHeader] 
      user.header = nil
    end
    
    unless params[:alerts].nil?
      alerts = user.alerts.nil? ? [] : user.alerts.split(',')
      alerts.push(params[:alerts])
      user.alerts = alerts.uniq.join(',')
    end

    if user.save
      result = { :success => true }
      result[:header] = user.header.url(:header) if !params[:user].nil? && !params[:user][:header].nil?
      render :json => result
    else
      render :json => { :success => false }
    end
    logger.debug 'completing update '
  end

  def cancel
    user = current_user
    @classes = 'home msg'
    @config = {:state => 'off'}.to_json

    if current_user == user && !current_user.banned?
      if current_user.deactivated?
        if user.deactivate(true)
          user.deactivated = false
          user.save
          verb = 'Reactivated'
        else
          verb = 'Failed to '+verb
        end
      else
        if user.deactivate
          user.deactivated = true
          user.save
          verb = 'Deactivated'
        else
          verb = 'Failed to '+verb
        end
      end
      render :inline => verb+' '+user.name+'<script type="text/javascript">(setTimeout( function() { document.location = "'+root_path+'"},5000) )()</script>', :layout => true
    else
      render :json => { :success => false, :message => 'WHY U TRY 2 STOP '+user.name }
    end
    
  end
  
  def access_pages 
    
    logger.debug ' access pages '
    newToken = RestClient.get 'https://graph.facebook.com/oauth/access_token?client_id='+ENV['FACEBOOK']+'&client_secret='+ENV['FACEBOOK_SECRET']+'&grant_type=fb_exchange_token&fb_exchange_token='+current_user.authentication_token
    logger.debug ' new token '+newToken

    current_user.update_attributes( :authentication_token => newToken.split('&')[0].gsub('access_token=','') ) # Refreshes the current token
    
    if !FbGraph::User.me( current_user.authentication_token ).permissions.include?(:manage_pages) # Uses FB Graph to check permissions
       logger.debug ' no permission '
      session[:origin] = request.env["HTTP_REFERER"]
      redirect_to 'https://www.facebook.com/dialog/oauth?client_id='+ENV['FACEBOOK']+'&redirect_uri='+ENV['BASE']+user_pages_path+'&scope=manage_pages,publish_stream&response_type=token'
    else # If has permission will download current page permissions and allow users to switch into them
       logger.debug ' has permission '
      json = JSON::parse(RestClient.get 'https://graph.facebook.com/me/accounts?access_token='+current_user.authentication_token)
      pages = json['data'].reject{ |p| p['category'] == 'Application'}
      
      pages = pages.map do |page|
        user = User.find_by_fb(page['id'])
        user_id = user.nil? ? nil : user.id
        { :fb => page['id'], :image => 'http://graph.facebook.com/'+page['id']+'/picture?type=square', :name => page['name'], :user => user_id, :authentication_token => page['access_token'] }
      end
      current_user.update_attributes( :pages => pages )
      origin = request.env["HTTP_REFERER"] || session[:origin]
      session.delete(:origin)

     logger.debug ' redirecting '
      redirect_to origin

    end
    
    
  end
  
  
  def page_session
    
    page_user = User.find_with_fb_id( params[:fb], current_user.pages.select{ |page| page[:fb] == params[:fb]}.first )


    session.delete(:logged_in_as) 
    session[:logged_in_as] = current_user.id
    
    sign_in page_user
    
    redirect_to :back
  end
  
  protected
    def check_user
      redirect_to root_path if current_user.nil?
    end
  
end