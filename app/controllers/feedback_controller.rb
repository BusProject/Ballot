class FeedbackController < ApplicationController
  def show
      feedback = params['name'].nil? ? Feedback.all : Feedback.find_all_by_choice_key(params['name'].split(','))

      render :json => feedback.to_json, :callback => params['callback']
  end

  def update
      
      feedback = params['feedback'] || []
      @json = []
      
      if user_signed_in?
        feedback.each do |f|
          feedback = Feedback.find_or_create_by_choice_key_and_user_id(f['choice_key'],f['user_id'])
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
