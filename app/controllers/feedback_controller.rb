class FeedbackController < ApplicationController

  def update
      feedbacks = params['feedback'] || [] # The feedback as posted in seralize fashion
      errors = []
      successes = []
      success = true
      if user_signed_in?
        feedbacks.each do |f|
          option = Option.find(f[1]['option_id'])
          feedback = option.feedback.new(
            :user => current_user,
            :comment => f[1]['comment'],
            :choice => option.choice
          )
          if feedback.save
            sucess = success && true
            successes.push({:obj => feedback.id })
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
    feedback = User.find(current_user).feedback.find(params[:id])
    render :json => feedback.delete, :callback  => params['callback']
  end



  def rate

    feedback = Feedback.find( params[:id] )
    flag = feedback[ params[:flavor] ]

    if flag.nil?
      render :json => {:success => false, :message => 'that is not a thing'  }, :callback  => params['callback']
    else
    
      flag = flag.split(',')
        
      verb = 'mark something as '+params[:flavor]
      verb = 'flag' if params[:flavor] == 'flag'

      if flag.length == 0
        msg = ''
      else
        noun = flag.length  == 1 ? 'person' : 'people'
        plural = flag.length == 1 ? 's' : ''
        msg = ', '+flag.length.to_s+' '+noun+' agree'+plural
      end
      msg = ', we\'ll review soon' if params[:flavor] == 'flag'
          
        
        
          if user_signed_in?
            if current_user.id == feedback.user_id
              render :json => {:success => false, :message => 'You can\'t '+verb+' your own thing' }, :callback  => params['callback']
            else
              if flag.index( current_user.id.to_s ).nil?
                flag.push(current_user.id)
                feedback[params[:flavor] ] = flag.join(',')

                if feedback.save
                  render :json => {:success => true, :message => 'Thanks'+msg, :feedback => feedback }, :callback  => params['callback']
                else
                  render :json => {:success => false, :message => 'Something went wrong', :feedback => feedbacks }, :callback  => params['callback']
                end

              else
                render :json => {:success => false, :message => 'You can\'t '+verb+' twice' }, :callback  => params['callback']
              end
            end
          else
            render :json => {:success => false, :message => '<a href="'+omniauth_authorize_path('user', :facebook)+'">You need to sign in</a> to '+verb }, :callback  => params['callback']
          end
    end  
  end

end
