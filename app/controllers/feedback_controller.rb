class FeedbackController < ApplicationController
  def show
      feedback = Feedback.find_all_by_choice_key(params['name'])
      @json = feedback
      render :partial => "layouts/api.json.erb"
  end


end
