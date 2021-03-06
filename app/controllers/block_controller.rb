class BlockController < ApplicationController
  # GET /blocks/1/edit
  def edit
    @classes =  'home'
    @block = Block.find(params[:id])
  end

  # POST /blocks
  # POST /blocks.json
  def create
    @block = Block.new
    if current_user.nil?
      flash[:notice] = t('guide.block_creation_failure')
    else
      @block.guide_id = params[:guide_id]
      if params[:option_id].nil? and !params[:custom_name].nil?
        @writein = UserOption.new
        @writein.name = params[:custom_name]
        @writein.choice_id = params[:contest_id]
        @writein.user_id = current_user.id
        @writein.save
        @block.user_option_id = @writein.id
      else
        @block.option_id = params[:option_id]
      end
      @block.title = params[:title]
      @block.block_order = params[:block_order] || 0
      @block.content = params[:content]
      @block.geography = params[:state]
      if @block.save
        flash[:notice] = t('guide.block_creation_success')
      end
    end
    redirect_to :back
  end

  # PUT /blocks/1
  # PUT /blocks/1.json
  def update
    @block = Block.find(params[:id])

    if @block.update_attributes(:title => params[:title], :block_order => params[:block_order].to_i, :content => params[:content], :geography => params[:state])
      flash[:notice] = t('guide.block_update_success')
    else
      flash[:notice] = t('guide.block_update_failure')
    end
    redirect_to :back
  end

  # DELETE /blocks/1
  # DELETE /blocks/1.json
  def destroy
    @block = Block.find(params[:id])
    @block.destroy
    flash[:notice] = t('guide.block_delete_flash')
    redirect_to :back
  end

  # POST /blocks/:id/half
  def half
    @block = Block.find(params[:id])
    if @block.full_size.nil?
      @block.full_size = true
    end
    @block.full_size = !@block.full_size
    @block.save
    redirect_to :back
  end

  def state
    guides = Guide.find_all_by_geography( params[:state] )
    render :json => guides.map{ |g| { :user => g.user.name, :name => g.name, :url => guide_show_path(g.slug) } }
  end

end
