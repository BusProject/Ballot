class UserController < ApplicationController
  before_filter :check_user

  def update
    user = current_user

    user.description = params[:description] unless params[:description] != 'null' && params[:description].nil?
    user.guide_name = params[:guide_name] unless params[:guide_name] != 'null' && params[:guide_name].nil?
    user.fb_friends = params[:fb_friends] unless params[:fb_friends].nil?

    unless params[:alerts].nil?
      alerts = user.alerts.nil? ? [] : user.alerts.split(',')
      alerts.push(params[:alerts])
      user.alerts = alerts.uniq.join(',')
    end

    if user.save
      render :json => { :success => true}
    else
      render :json => { :success => false }
    end
    
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
    
    json = JSON::parse(RestClient.get 'https://graph.facebook.com/me/accounts?access_token='+current_user.authentication_token)
    pages = json['data'].reject{ |p| p['category'] == 'Application'}

    if pages.empty? && current_user.pages.nil? && session[:origin].nil?
      session[:origin] = request.env["HTTP_REFERER"]
      redirect_to 'https://www.facebook.com/dialog/oauth?client_id='+ENV['FACEBOOK']+'&redirect_uri='+ENV['BASE']+user_pages_path+'&scope=manage_pages&response_type=token'
    else
      pages = pages.map do |page|
        user = User.find_by_fb(page['id'])
        user_id = user.nil? ? nil : user.id
        { :fb => page['id'], :image => 'http://graph.facebook.com/'+page['id']+'/picture?type=square', :name => page['name'], :user => user_id, :authentication_token => page['access_token'] }
      end

      current_user.update_attributes( :pages => pages )

      origin = request.env["HTTP_REFERER"] || session[:origin]
      session.delete(:origin)

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