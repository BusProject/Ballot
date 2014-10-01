class ChoiceController < ApplicationController

  def new
    @classes = 'home add'

    @choice = Choice.new( :contest_type => params[:type] == 'measure' ? 'User_Ballot' : 'User_Candidate' )

    @config =  { :state => 'not' }.to_json

    render :template => 'choice/add'
  end


  def create
    if current_user.nil?
      render :text => 'no'
    else
      @states = Choice.states
      @abvs = Choice.stateAbvs
      geography = [@abvs[ @states.index( params[:choice][:geography] ) ],'User',current_user.id.to_s,Time.now.to_i.to_s].join('_')

      if params[:choice][:contest_type] == 'User_Candidate'
        @choice = Choice.new(
          :contest => params[:choice][:contest],
          :geography => geography,
          :votes => params[:choice][:votes].to_i,
          :contest_type => params[:choice][:contest_type],
          :options_attributes => params[:choice][:options_attributes]
        )
      else
        params[:choice][:options_attributes].each{ |k,v| v[:blurb_source] = params[:choice][:blurb_source] }
        @choice = Choice.new(
          :contest => params[:choice][:contest],
          :description => params[:choice][:description],
          :geography => geography,
          :contest_type => params[:choice][:contest_type],
          :options_attributes => params[:choice][:options_attributes]
        )
      end
      if @choice.save
        redirect_to contest_path( @choice.geography, @choice.contest.gsub(' ','_'))
      else
        redirect_to user_add_choice_path, :error => @choice.errors
      end
    end
  end

  def friends

    @classes = 'profile home friends'
    @feedback = Feedback.friends( current_user )

    result = {:state => 'friends' }

    @config = result.to_json

  end

  def profile

    if params[:profile].to_i(16).to_s(16) == params[:profile]
      @user = User.find_by_id( params[:profile].to_i(16).to_s(10).to_i(2).to_s(10) )
    else
      @user = User.find_by_profile( params[:profile] )
    end

    raise ActionController::RoutingError.new('Could not find that user') if @user.nil?

    choices = @user.choices
    more = ! params[:past] && !@user.choices.empty?

    @choices = choices.uniq.sort_by{ |choice| [ Choice.contest_type_order.index( choice.contest_type), choice.geography, choice.geography.slice(-3).to_i ]  }.each{ |c| c.prep current_user; c.addUserFeedback @user }

    if !current_user.nil? && current_user != @user
      @recommended = true
      @user.feedback.each{ |f|  @recommended = @recommended & current_user.voted_for?(f) }
    end

    @classes = 'profile home'
    @title = !@user.guide_name.nil? && !@user.guide_name.strip.empty? ? @user.guide_name : @user.name+"'s Voter Guide"
    @type = 'Voter Guide'
    @message = !@user.description.nil? && !@user.guide_name.strip.empty? ? @user.description : 'A Voter Guide by '+@user.first_name+', powered by The Ballot.'

    @guides = Guide.where(:user_id => @user.id)

    result = {:state => 'profile', :user => @user.to_public(false), :more => more }

    @config = result.to_json
    @choices_json = @choices.to_json( Choice.to_json_conditions )

    @type = '';
    if !@user.fb.nil?
      #@type = ENV['FACEBOOK_NAMESPACE']+':voter_guide'
    end
  end

  def state

    if request.method == 'POST'
      @choices = Choice.find_by_state(params[:state], 500, 0 )
    else
      @choices = Choice.find_by_state(params[:state], 50, params[:page] || 0 )
    end

    raise ActionController::RoutingError.new('Could not find that state') if @choices.nil?

    @choices = @choices.each{ |c| c.prep current_user }

    if params[:format] == 'json'
      if request.method == 'POST'
        render :json => @choices.to_json( :only => [:contest, :id, :contest_type], :include => {:options => { :only => [ :name, :id]  } } )
      else
        render :json => @choices.to_json( Choice.to_json_conditions )
      end
    else
      @types = Choice.types_by_state( params[:state] )

      @states = Choice.states
      @stateAbvs = Choice.stateAbvs

      @state = @states[ @stateAbvs.index( params[:state] ) ]

      @classes = 'home state'
      @title = @state+'\'s Full Ballot'
      @type = 'Voter Guide'
      @message = @state+'\'s Full Ballot, powered by The Ballot.'

      result = {:state => 'state', :choices => @choices, :title => @title, :message => @message }

      @choices_json = @choices.to_json

      @config = result.to_json
    end

  end

  def show
    @choice = Choice.find_office(params[:geography],params[:contest].gsub('_',' '))

    raise ActionController::RoutingError.new('Could not find '+params[:contest].gsub('_',' ') ) if @choice.nil?

    @classes = 'single home'
    @title = @choice.contest
    @partial = @choice.contest_type.downcase.index('ballot').nil? ? 'candidate/front' : 'measure/front'
    @type = @partial == 'candidate/front' ? ENV['FACEBOOK_NAMESPACE']+':candidate' : ENV['FACEBOOK_NAMESPACE']+':ballot_measure'
    @message = @partial == 'measure/front' ? @choice.description : 'An election for '+@choice.contest+' between '+@choice.options.map{|o| o.name+'('+( o.party || '' )+')' }.join(', ')

    result = {:state => 'single', :choices => [ @choice ].each{ |c| c.prep current_user } }

    @config = result.to_json( Choice.to_json_conditions )

  end

  def index
    @choices = Choice.find_by_address( params[:a] || params[:address] ).each{ |c| c.prep current_user }
    render :json => @choices.to_json( Choice.to_json_conditions )
  end

  def more
    choice = Choice.find_by_id(params[:id])
    @feedback = choice.more( params[:page], current_user )
    render :json => @feedback
  end
end
