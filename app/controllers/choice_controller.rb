class ChoiceController < ApplicationController
  def json_include
    return :include => [ 
    :options => { 
      :include => [
        :feedback 
        ] 
      }
    ]
  end
  
  def profile
    @user = User.find( params[:id].to_i(16).to_s(10).to_i(2).to_s(10) )

    @choices = @user.choices.each{ |c| c.prep current_user }
    @classes = 'profile home'
    @title = @user.guide_name.nil?  ? @user.name+'\'s Voter Guide' : @user.guide_name

    result = {:state => 'profile', :choices => @choices, :user => @user }

    @config = result.to_json( json_include )

  end
  
  def show
    @choice = Choice.find_by_geography_and_contest(params[:geography],params[:contest].gsub('_',' '))

    raise ActionController::RoutingError.new('Not Found') if @choice.nil?

    @classes = 'home single'
    @title = @choice.contest

    result = {:state => 'single', :choices => [ @choice ].each{ |c| c.prep current_user } }

    @config = result.to_json( json_include )

  end

  def index
    
    districts = params['q'].nil? ? Cicero.find(params['l'], params[:address] ) : params['q'].split('|')
    
    unless districts.nil?
      @choices = Choice.find_all_by_geography( districts ).each{ |c| c.prep current_user }
    else
      query = {'success' => false, 'message' => 'Nothing useful was posted'}.to_json
    end
    
    render :json => @choices.to_json( json_include )
  end
  
  def retrieve
    if user_signed_in? && ( current_user.admin || current_user.id == 1) || Rails.env.development?
    
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

  def more
    choice = Choice.find_by_id(params[:id])
    @feedback = choice.more( params[:page], current_user )
    render :json => @feedback
  end
end
