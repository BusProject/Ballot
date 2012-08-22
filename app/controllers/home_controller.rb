class HomeController < ApplicationController
  def index
    if current_user.nil? && !cookies['new_ballot_visitor']

      cookies['new_ballot_visitor'] = {
        :value => true,
        :expires => 2.weeks.from_now
      }      
      @config = { :state => 'splash' }.to_json
      @classes = 'splash'

      render :template => 'home/splash.html.erb'
    else
      render :template => 'home/index.html.erb' 
    end
  end
end
