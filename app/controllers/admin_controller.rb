class AdminController < ApplicationController
  before_filter :check_admin
  
  def index
    @classes = 'home admin'
    @admins = User.find_all_by_admin(true)
    @bans = User.find_all_by_banned(true)
    @flagged = Feedback.where( "length(flag)- length(replace( flag,',','') ) >= ? AND approved = ?", 2, true )
    @flagged.concat( Feedback.where('approved = ?',false).joins(:user).where('banned = ? AND deactivated = ? AND admin = ?',false,false,false) )
    @userGenerated = Choice.where('geography LIKE ?','%User%')
    
    # this query will be useful sometime: it is the geography of the races that have recieved comments:
    # Feedback.all.map{ |f| f.choice.geography }.uniq.sort.each{ |c| puts c }
    
    @config = {:state => 'off'}.to_json
  end
  
  def find
    prepped = '%'+params[:term].split(' ').map{ |word| word.downcase }.join(' ')+'%'
    if params[:object] == 'users'
      users = User.where( "lower(name) LIKE ? OR lower(last_name) LIKE ? OR lower(first_name) LIKE ? OR lower(email) LIKE ? OR id = ?", prepped, prepped, prepped, prepped, params[:term].gsub(ENV['BASE'],'').gsub(root_path,'').to_i(16).to_s(10).to_i(2).to_s(10) )      
      results = users.map{ |user| {:label => user.name, :id => user.id, :ban_url => user_ban_path( user.id ) , :admin_url => user_admin_path( user.id ) } }
    elsif params[:object] == 'feedback'
      feedback = Feedback.where( "lower(comment) LIKE ? AND approved = ?", '%'+params[:term]+'%',true)
      feedback.concat( User.where( "lower(name) LIKE ? OR lower(last_name) LIKE ? OR lower(first_name) LIKE ? OR lower(email) LIKE ? OR id = ?", prepped, prepped, prepped, prepped, params[:term].gsub(ENV['BASE'],'').gsub(root_path,'').to_i(16).to_s(10).to_i(2).to_s(10) ).map{ |user| user.feedback.select{ |feedback| feedback.approved? } }.flatten )
      results = feedback.map{ |feedback| {:label => ['"'+feedback.comment+'"',' - ',feedback.user.name,'on',feedback.choice.contest].join(' '), :id => feedback.id, :approval_url => approval_feedback_path( feedback.id ) } }
    elsif params[:object] == 'choice'
      choices = Choice.where( "lower(contest) LIKE ?", prepped)
      choices.concat( Option.where( 'lower(name) LIKE ?',prepped).map{ |option| option.choice}.flatten.uniq )
      results = choices.map{ |choice| {:label => choice.contest+' - '+choice.options.map{|c| c.name}.join(', '), :id => choice.id, :edit_url => choice_edit_path(choice.id) } }
    end
    render :json => results
  end
  
  def ban
    user = User.find_by_id( params[:id] )
    user.banned = !user.banned
    verb = user.banned ? 'banned' : 'unbanned'
    if !user.admin? && user.save && user.deactivate( !user.banned )
      render :json => { :success => true, :message => user.name+' is now '+verb, :user => user }
    else
      render :json => { :success => false, :message => user.name+' could not be '+verb }
    end
  end

  def admin
    user = User.find_by_id( params[:id] )
    user.admin = !user.admin
    if !user.admin && user.created_at < current_user.created_at
      render :json => { :success => false, :message => user.name+' could not be be unmade an admin - they\'re older than you' }
    else
      if user.save
        render :json => { :success => true, :message => user.name+' is now an admin', :user => user }
      else
        render :json => { :success => false, :message => user.name+' could not be made an admin' }
      end 
    end
  end

  def feedback
    feedback = Feedback.find_by_id( params[:id] )
    feedback.approved = feedback.off?
    verb = feedback.approved ? 'approved' : 'unapproved'
    feedback.flag = '' if feedback.approved
    if feedback.save
      render :json => { :success => true, :message => feedback.comment+' is now '+verb, :delete_url => remove_feedback_path(feedback.id), :feedback => feedback, :user => feedback.user }
    else
      render :json => { :success => false, :message => feedback.comment+' could not be '+verb }
    end
  end
  
  def choice_edit
    @choice = Choice.includes( :options ).find(params[:id])
    render :template => 'choice/_form', :layout => false
  end

  def choice_update
    @choice = Choice.find(params[:id])
    @choice.update_attributes( params[:choice] )
    render :json => { :option => @choice.options, :params => params}
  end
  
  def choice_delete
    @choice = Choice.find(params[:id])

    unless params[:reassign].nil?
      url = params[:reassign].gsub(ENV['BASE'],'').split('/')
      contest = url.pop.gsub('_',' ')
      geography = url.pop.gsub('%20',' ')
      reassign = Choice.find_by_geography_and_contest(geography,contest)
      message = ''

      unless reassign.nil?
        success = true      
        @choice.feedback.each do |feedback|
          option = reassign.options.select{ |option| option.name.split(' ').last == feedback.option.name.split(' ').last && option.name.split(' ').first == feedback.option.name.split(' ').first }.first
          if option.nil?
            success = false && success
          else
            double = Feedback.where('choice_id = ? AND option_id = ? AND user_id = ?',reassign.id, option.id, feedback.user_id).count == 0
            if double
              feedback.option =  option
              feedback.choice = reassign
              feedback.save
            end
            success = true && success
          end
        end
        
        @choice.fullDelete if success
        message = 'Moved to '+ENV['BASE']+contest_path( reassign.geography, reassign.contest.gsub('_',' ') )
      else
        success = false
        message = 'Could not find - searched deets are '+['geography:',geography,'contest:',contest].join(' ')
      end

    else 
      @choice.fullDelete
      success = true
    end
    
    render :json => { :success => success, :message => message }
  end

  def option_delete
    @option = Option.find(params[:id])
    @option.delete
    render :json => { :success => true }
  end

  def import_candidates
    require 'csv'
    require 'active_support/all'
    require File.expand_path( File.join('lib', 'process.rb') )

    @headers = params[:headers]
    file = params[:"candidates-import"].path
    row = 0

    CSV.foreach(file, {:headers => @headers}) do |data|
      #skip the header row 
      if row == 0
        row += 1
        next
      end

      # begin
      obj = {}
      ii=0
      data.each do |d|
        unless d.nil?
          obj[ @headers[ii] ] = ActiveSupport::Inflector.transliterate(d)
        end
        ii+=1
      end
      newobj = addCandidate(obj)
      row+=1
    end
    render :json => { :success => true }
  end

  def import_measures
    require 'csv'
    require 'active_support/all'

    @headers = params[:headers]
    file = params[:"measures-import"].path
    row = 0

    CSV.foreach(file, {:headers => @headers}) do |data|
      #skip the header row 
      if row == 0
        row += 1
        next
      end

      obj = {}
      ii=0

      data.each do |d|
        unless d.nil?
          obj[ @headers[ii] ] = ActiveSupport::Inflector.transliterate(d)
        else
          obj[ @headers[ii] ] = ''
        end
        
        ii+=1
      end


      row_choice = { :geography => obj['State'], :contest => obj['Title'], :contest_type => 'Ballot_Statewide', :description => obj['Subtitle'] }
      row_option1 = { :name => obj['Response 1'], :blurb => obj['Response 1 Blurb'], :blurb_source => obj['Text'] }
      row_option2 = { :name => obj['Response 2'], :blurb => obj['Response 2 Blurb'], :blurb_source => obj['Text'] }

      choice = Choice.find_or_create_by_geography_and_contest( row_choice[:geography],row_choice[:contest],row_choice)    
      choice.update_attributes(row_choice)
      choice.save
      option = choice.options.find_or_create_by_name( row_option1[:name], row_option1)
      option.update_attributes(row_option1)
      option.save
      
      option = choice.options.find_or_create_by_name( row_option2[:name], row_option2)
      option.update_attributes(row_option2)
      option.save

      row+=1
    end
    render :json => { :success => true }
  end
  
  protected
    def check_admin
      redirect_to root_path unless !current_user.nil? && current_user.admin?
    end
end
