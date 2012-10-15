class FeedbackController < ApplicationController

  def update
      feedbacks = params['feedback'] || [] # The feedback as posted in seralize fashion
      errors = []
      successes = []
      success = true
      if user_signed_in? && current_user.commentable?
        feedbacks.each do |f|
          if f[1]['option_id'] == 'NaN'
            choice = Choice.find( f[1]['choice_id'] )
            feedback = choice.feedback.new(
              :user => current_user,
              :comment => f[1]['comment']
            )
          else
            option = Option.find(f[1]['option_id'])
            feedback = option.feedback.new(
              :user => current_user,
              :comment => f[1]['comment'],
              :choice => option.choice
            )
          end
          if feedback.save
            success = success && true
            successes.push({:obj => feedback.id, :updated_at => feedback.updated_at })
          else
            success = success && false
            errors.push( {:obj => feedback.id, :success => false, :error => feedback.errors })
          end
          @json = {'success' => success, 'errors' => errors, 'successes' => successes }
        end
        @json = {'success'=>false, 'message'=>'Are you trying to tell me something user #'+current_user.id.to_s+'?'} if feedbacks.empty?
      else
        @json = {'success'=>false, 'message'=>'You must sign in to save feedback'}
      end
      
      render :json => @json, :callback => params['callback']
  end

  def delete
    if current_user.admin?
      feedback = Feedback.find(params[:id])
    else
      feedback = User.find(current_user).feedback.find(params[:id])
    end
    render :json => { :feedback => feedback.delete, :success => true }, :callback  => params['callback']
  end

  def vote
    unless current_user.nil?
      feedback = Feedback.find( params[:id] )

      if  params[:flavor] == 'useful'
        amount = feedback.upvotes.size
        current_user.likes feedback
      else
        amount = feedback.upvotes.size
        current_user.likes feedback
      end

      render :json => {:success => true, :message => I18n.t('feedback.agree',{:count => amount, :attribute => params[:flavor] }) }, :callback  => params['callback']
    else
      render :json => {:success => false, :callback  => params['callback'] }
    end
  end
  
  def show
    @feedback = Feedback.find( params[:id] )
    @user = @feedback.user
    
    raise ActionController::RoutingError.new('Could not find that feedback') if @feedback.nil? 
    
    @choices = [ @feedback.choice ].each{ |c| c.prep current_user; c.addUserFeedback @feedback.user }
    
    if !current_user.nil? && current_user != @feedback.user
      @recommended = current_user.voted_for?( @feedback )
    end
    
    @classes = 'profile home'
    @title =  'A comment from '+(!@user.guide_name.nil? && !@user.guide_name.strip.empty? ? @user.guide_name : @user.name+'\'s Voter Guide')
    
    @message = @feedback.comment
    
    @image = @feedback.memes.last.nil? ? nil : ENV['BASE']+meme_show_image_path( @feedback.memes.last.id )+'.png'
    
    result = {:state => 'profile', :user => @user.to_public(false) }
    
    @config = result.to_json
    @single = true

    @type = ENV['FACEBOOK_NAMESPACE']+':comment'

    @choices_json = @choices.to_json( Choice.to_json_conditions )
    render :template => 'choice/profile'
  end

  def flag

    feedback = Feedback.find( params[:id] )
    flag = feedback.flag
    
    params[:flavor] = 'flag'

    if flag.nil?
      render :json => {:success => false, :message => ''  }, :callback  => params['callback']
    else
    
      flag = flag.split(',')
        
        
      if user_signed_in? && current_user.commentable?
        if current_user.id == feedback.user_id
          render :json => {:success => false, :message => '' }, :callback  => params['callback']
        else
          if flag.index( current_user.id.to_s ).nil?
            flag.push(current_user.id)
            feedback[params[:flavor] ] = flag.join(',')

            if feedback.save
              render :json => {:success => true, :message => '' }, :callback  => params['callback']
            else
              render :json => {:success => false, :message => '' }, :callback  => params['callback']
            end

          else
            render :json => {:success => false, :message => '' }, :callback  => params['callback']
          end
        end
      else
        render :json => {:success => false, :message => '' }, :callback  => params['callback']
      end
    end
  end

end
