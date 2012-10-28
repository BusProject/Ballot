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
    @choice.fullDelete
    render :json => { :success => true }
  end

  def option_delete
    @option = Option.find(params[:id])
    @option.delete
    render :json => { :success => true }
  end
  
  protected
    def check_admin
      redirect_to root_path unless !current_user.nil? && current_user.admin?
    end
end
