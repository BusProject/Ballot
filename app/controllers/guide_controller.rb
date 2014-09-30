class GuideController < ApplicationController
  before_filter :check_user, except: [:show]

  # GET /guides/1
  # GET /guides/1.json
  # guide_id and user_id are mixed up.
  def show
    @guide = Guide.find_by_slug( params[:id].downcase )
    @classes = 'home'
    raise ActionController::RoutingError.new('Could not find that guide') if @guide.nil?

    if !@guide.publish and @guide.user_id != current_user.id
      flash[:notice] = t('guide.not_published')
      redirect_to :back
    end
    @user = current_user
    @blocks = Block.where(:guide_id => @guide.id)
    @choices = Choice.all()
    @options = Option.all()
    @writeins = UserOption.all()
  end

  # GET /guides/1/edit
  def edit
    @guide = Guide.find(params[:id])
    @classes = 'home'
    @user = current_user
    @blocks = Block.where(:guide_id => params[:id])
    @writeins = UserOption.all()
  end

  # POST /guides
  # POST /guides.json
  def create
    @guide = Guide.new
    @guide.user = current_user
    @guide.slug = Devise.friendly_token[0,20].downcase
    if @guide.save
      flash[:notice] = t('guide.creation_success')
    end
    redirect_to :back
  end

  # PUT /guides/1
  # PUT /guides/1.json
  def update
    params[:slug] = params[:slug].downcase
    @guide = Guide.where(['slug = ? AND id <> ?', params[:slug], params[:id]])

    if @guide.any?
      flash[:notice] = t('guide.slug_not_unique')
    else
      @guide = Guide.find(params[:id])

      if @guide.update_attributes(:slug => params[:slug], :name => params[:name], :publish => params[:publish])
        flash[:notice] = t('guide.update_success')
      else
        flash[:notice] = t('guide.update_failure')
      end
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
