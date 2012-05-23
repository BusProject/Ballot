class FeedbackController < ApplicationController

  def update
      feedback = params['feedback'] || [] # The feedback as posted in seralize fashion
      @json = []
      
      if user_signed_in?
        feedback.each do |f|
          feedback = Feedback.find_or_create_by_option_id_and_user_id(f['option_id'],f['user_id'])
          feedback.comment = f['comment']
          feedback.support = f['support']
          if feedback.save
            @json.push({:obj => feedback.id, :success => true })
          else
            @json.push({:obj => feedback.id, :success => false, :error => feedback.errors })
          end
        end
      else
        @json = {'success'=>false, 'message'=>'You must sign in to save feedback'}
      end
      
      render :json => @json.to_json, :callback => params['callback']
  end


end
