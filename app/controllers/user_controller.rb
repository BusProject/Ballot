class UserController < ApplicationController

  def show
    user = User.find( params[:id].to_i(16).to_s(10).to_i(2).to_s(10) )
    render :json => user
  end

end