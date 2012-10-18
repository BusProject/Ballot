class FeedbackController < ApplicationController

  def update
      feedbacks = params['feedback'] || [] # The feedback as posted in seralize fashion
      errors = []
      successes = []
      success = true
      if user_signed_in? && current_user.commentable?
        feedbacks.each do |f|
          option = Option.find(f[1]['option_id'])
          feedback = option.feedback.new(
            :user => current_user,
            :comment => f[1]['comment'],
            :choice => option.choice
          )
          if feedback.save
            sucess = success && true
            successes.push({:obj => feedback.id, :updated_at => feedback.updated_at })
            
            type = feedback.choice.contest.index('Ballot').nil? ? 'candidate' : 'measure'
            url = show_feedback_path( feedback.id )
            RestClient.post 'https://graph.facebook.com/me/the-ballot:recommend?access_token='+current_user.authentication_token+'&'+type+'='+url
          else
            sucess = success && false
            errors.push({:obj => feedback.id, :success => false, :error => feedback.errors })
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
    
    @message = @feedback.comment
    
    unless params[:guide]
      if @choices[0].contest_type.index('Ballot').nil? 
        @title = 'Vote '+@feedback.option.name+' for '+@choices.first.contest
        type ='candidate'
        @message = I18n.t('site.voted', { :count => @choices.first.feedback.votes } )+', '+I18n.t('site.commented', { :count => @choices.first.feedback.comments } ) if @message.nil? || @message.empty?
      else
        @title = 'Vote '+@feedback.option.name+' on '+@choices.first.contest
        type = 'ballot_measure'
        @message = @choices.first.description if @message.nil? || @message.empty?
      end
      @geography = @choices.first.geographyNice(false)
      @redirect = @choices.first.to_url
    else
      @title =  'A comment from '+(!@user.guide_name.nil? && !@user.guide_name.strip.empty? ? @user.guide_name : @user.name+'\'s Voter Guide')

      type = 'comment'
    end
    
    @image = @feedback.memes.last.nil? ? @feedback.user.image : ENV['BASE']+meme_show_image_path( @feedback.memes.last.id )+'.png'
    
    result = {:state => 'profile', :user => @user.to_public(false) }
    
    @config = result.to_json
    @single = true

    @type = ENV['FACEBOOK_NAMESPACE']+':'+type

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
