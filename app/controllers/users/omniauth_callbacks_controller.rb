class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user )

    if params[:state]
      alerts =  @user.alerts.nil? ? [] : @user.alerts.split(',')
      alerts = [] if alerts.nil?
      alerts.push( params[:state] )
      @user.alerts = alerts.uniq.join(',')
      @user.save if @user.persisted?
    end

    @user.remember_me! # Remembering the user when logging in

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end