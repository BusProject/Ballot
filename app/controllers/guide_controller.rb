class GuideController < ApplicationController
  before_filter :check_user, except: [:show]

  # GET /guides/1
  # GET /guides/1.json
  def show
    @guide = Guide.find(params[:id])
    if !@guide.publish
      flash[:notice] = t('guide.not_published')
      redirect_to :back
    end
    @user = current_user
    @blocks = Block.where(:guide_id => params[:id])
    @choices = Choice.all(:select => "id, geography, contest, description", :order => "geography, contest")
    @options = Option.all(:select => "id, choice_id, name, party, blurb", :order => "choice_id, name")
    @writeins = UserOption.all(:select => "id, choice_id, name", :order => "choice_id, name")
  end

  # GET /guides/1/edit
  def edit
    @guide = Guide.find(params[:id])
    @user = current_user
    @blocks = Block.where(:guide_id => params[:id])
    @choices = Choice.all(:select => "id, geography, contest, description", :order => "geography, contest")
    @options = Option.all(:select => "id, choice_id, name, party, blurb", :order => "choice_id, name")
    @writeins = UserOption.all(:select => "id, choice_id, name", :order => "choice_id, name")
  end

  # POST /guides
  # POST /guides.json
  def create
    @guide = Guide.new
    @guide.user = current_user
    if @guide.save
      flash[:notice] = t('guide.creation_success')
    end
    redirect_to :back
  end

  # PUT /guides/1
  # PUT /guides/1.json
  def update
    @guide = Guide.find(params[:id])

    if @guide.update_attributes(:id => params[:id], :name => params[:name], :publish => params[:publish])
      flash[:notice] = t('guide.update_success')
    else
      flash[:notice] = t('guide.update_failure')
    end
    redirect_to :back
  end

  # DELETE /guides/1
  # DELETE /guides/1.json
  def destroy
    @guide = Guide.find(params[:id])
    @guide.destroy
    flash[:notice] = t('guide.delete_flash')
    redirect_to :back
  end

  protected
    def check_user
      redirect_to root_path if current_user.nil?
    end
end
