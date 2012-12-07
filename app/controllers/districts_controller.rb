class DistrictsController < ApplicationController
  # before_filter :check_admin

  def index
    @classes = 'home admin'
    @content =  ['<ul style="margin-top: 40px;"><li>',District.all.map(&:name).join("</li><li>"),'</li></ul>'].join('')
    render :template => 'home/show'
  end
  
  def create
    
    district = District.new( params[:district] )
    
    district.save
    
    redirect_to districts_path
  end
  
  def new
    @classes = 'home add admin'
    
    @district = District.new
    
    @config = {:state => 'off'}.to_json
    
    render :template => 'admin/districts/add'
  end
  
  # protected
  #   def check_admin
  #     redirect_to root_path unless !current_user.nil? && current_user.admin?
  #   end
  
end