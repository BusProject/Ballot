class GuideController < ApplicationController
  # GET /guides/1
  # GET /guides/1.json
  def show
    @guide = Guide.find(params[:id])
  end

  # GET /guides/1/edit
  def edit
    @guide = Guide.find(params[:id])
    @user = current_user
    @blocks = Block.where(:guide_id => params[:id])
    @choices = Choice.all(:select => "id, geography, contest", :order => "geography, contest")
    @options = Option.all(:select => "id, choice_id, name, party", :order => "choice_id, name")
    @writeins = UserOption.all(:select => "id, choice_id, name", :order => "choice_id, name")
  end

  # POST /guides
  # POST /guides.json
  def create
    if current_user.nil?
      flash[:notice] = t('guide.creation_failure')
    else
      @guide = Guide.new
      @guide.user = current_user
      if @guide.save
        flash[:notice] = t('guide.creation_success')
      end
    end
    redirect_to :back
  end

  # PUT /guides/1
  # PUT /guides/1.json
  def update
    @guide = Guide.find(params[:id])

    if @guide.update_attributes(params)
      flash[:notice] = t('guide.update_failure')
      redirect_to profile_path(current_user)
    else
      flash[:notice] = t('guide.update_success')
      redirect_to :back
    end
  end

  # DELETE /guides/1
  # DELETE /guides/1.json
  def destroy
    @guide = Guide.find(params[:id])
    @guide.destroy
    flash[:notice] = t('guide.delete_flash')
    redirect_to :back
  end
end
