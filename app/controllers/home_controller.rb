class HomeController < ApplicationController
  def index
    @classes = 'home '
    if current_user.nil? && !cookies['new_ballot_visitor'] && params['q'].nil?

      cookies['new_ballot_visitor'] = {
        :value => true,
        :expires => 2.weeks.from_now
      }      
      @config = { :state => 'splash' }.to_json
      @classes += 'splash'

      render :template => 'home/splash.html.erb'
    else
      render :template => 'home/index.html.erb' 
    end
  end
  
  def about
    @classes = 'home msg'
    @config = { :state => 'page' }.to_json
    @title = 'About'
    @content = "
         <p>TheBallot.org is the 100% social voter guide brought to you by the League of Young Voters, New Era Colorado, Forward Montana, and the Bus Project.</p>
         <p>Some cool stuff about TheBallot.org:</p>
         <ul>
          <li>This is a crowdsourced voter guide. The content and order in which it appears is determined by the wisdom of the masses, not by political powerbrokers.</li>
          <li>This is open-source software. Our commitment to crowdsourcing doesn't stop with ballot measures. We've built this software open source so that others can modify and improve it. Want to check it out? <a href='github.com/busproject/ballot' target='_blank'>Here's our GitHub repo</a> - fork away! Want to help? Let us know. We're also utilizing and supporting the Voter Information Project so that other similar projects can piece together the relevant and accurate ballot information for free.</li>
          <li><a href='/'>Get started using the Ballot now</a></li>
         </ul>"
    render 'home/show'
  end
  
end
