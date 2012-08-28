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
  
  protected
    def check_user
      redirect_to root_path if current_user.nil?
    end
  
end