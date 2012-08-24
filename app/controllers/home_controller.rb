class HomeController < ApplicationController
  def index
    @classes = 'home '
    if current_user.nil? && !cookies['new_ballot_visitor']

      cookies['new_ballot_visitor'] = {
        :value => true,
        :expires => 2.weeks.from_now
      }      
      @config = { :state => 'splash' }.to_json
      @classes += 'splash'

      render :template => 'home/splash.html.erb'
    else
      render :template => 'home/index.html.erb' 
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
      render :json => { :success => false, :message => 'WHY U TRY 2 BAN '+user.name }
    end
    
  end
end
