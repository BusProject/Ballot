class ChoiceController < ApplicationController
  def show
    
    districts = params['q'].nil? ? Cicero.find(params['l']) : params['q'].split('|')
    
    unless districts.nil?
      
      choices = Choice.find_all_by_geography( districts )
      
      unless params['group'].nil?
        results = []
        districts.each do |district|
         results.push( { 'geography' => district, 'choices' => choices.select{ |choice| choice.geography == district } } )
        end
      else
        results = choices
      end

      query = results.to_json( 
        :include => [ 
          :options => { 
            :include => [ 
              :feedback => {
                :include => [ 
                  :user => { 
                    :only => [ :url, :first_name, :last_name, :url, :location, :image ] 
                    } 
                  ] 
                } 
              ] 
            }
          ])

    else
      query = {'error' => true, 'message' => 'Nothing useful was posted'}.to_json
    end
    
    render :json => query, :callback => params['callback']
  end
  
  def retrieve
    if user_signed_in? && current_user.id == 1
    
      choice_sheet = 'https://spreadsheets.google.com/feeds/list/0AnnQYxO_nUTWdDU2RHFZS3BMTDAzZmFNTXhGRFBReWc/1/public/basic'
      option_sheet = 'https://spreadsheets.google.com/feeds/list/0AnnQYxO_nUTWdDU2RHFZS3BMTDAzZmFNTXhGRFBReWc/2/public/basic'

      raw_choices = Google.getFeed(choice_sheet)
      raw_options = Google.getFeed(option_sheet)
      choices = []

      raw_choices.each do |raw_choice|
        shell_choice = Google.extractContent(raw_choice['content'])
        choice = Choice.find_or_create_by_geography_and_contest(shell_choice['geography'], shell_choice['contest'],shell_choice)
        choice.update_attributes(shell_choice)
        choices.push(choice)
        choices.last['options'] = []

        raw_options.select{ |option| option['title'] == raw_choice['title'] }.each do |raw_option|
          shell_option = Google.extractContent(raw_option['content'])

          option = choice.options.find_or_create_by_name(shell_option['name'], shell_option)
          option.update_attributes(shell_option)
        end
      end

    else
      choices = {'error' => true, 'message' => 'Yeah you can\'t just DO that'} 
    end
    
    render :json => choices, :callback => params['callback']
  
  end

end
