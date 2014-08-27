class UserOptionController < ApplicationController
  # GET /user_options/new
  # GET /user_options/new.json
  def new
    @user_option = UserOption.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_option }
    end
  end

  # GET /user_options/1/edit
  def edit
    @user_option = UserOption.find(params[:id])
  end

  # POST /user_options
  # POST /user_options.json
  def create
    @user_option = UserOption.new(params[:user_option])

    respond_to do |format|
      if @user_option.save
        format.html { redirect_to @user_option, notice: 'User option was successfully created.' }
        format.json { render json: @user_option, status: :created, location: @user_option }
      else
        format.html { render action: "new" }
        format.json { render json: @user_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_options/1
  # PUT /user_options/1.json
  def update
    @user_option = UserOption.find(params[:id])

    respond_to do |format|
      if @user_option.update_attributes(params[:user_option])
        format.html { redirect_to @user_option, notice: 'User option was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_options/1
  # DELETE /user_options/1.json
  def destroy
    @user_option = UserOption.find(params[:id])
    @user_option.destroy

    respond_to do |format|
      format.html { redirect_to user_options_url }
      format.json { head :no_content }
    end
  end
end
