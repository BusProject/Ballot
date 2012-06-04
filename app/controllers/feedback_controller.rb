class FeedbackController < ApplicationController

  def update
      feedbacks = params['feedback'] || [] # The feedback as posted in seralize fashion
      errors = []
      successes = []
      success = true
      if user_signed_in?
        feedbacks.each do |f|
          feedback = Option.find(f[1]['option_id']).feedback.new(
            :user => current_user,
            :comment => f[1]['comment'],
            :support => f[1]['support'] 
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

end
