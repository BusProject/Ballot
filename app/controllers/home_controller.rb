class HomeController < ApplicationController
  def index
    @classes = 'home '
    cookename = 'new_'+Rails.application.class.to_s.split("::").first+'_visitor'
    if current_user.nil? && !cookies[cookename] && params['q'].nil?

      cookies[cookename] = {
        :value => true,
        :expires => 2.weeks.from_now
      }      
      @config = { :state => 'splash' }.to_json
      @classes += 'splash'

      render :template => 'home/splash.html.erb'
    else
      params['q'] = params['q'] || params['address']
      
      @config = { :address => params['q'].gsub('+',' ') }.to_json unless params['q'].nil?
      @classes = 'home front'
      
      render :template => 'home/index.html.erb' 
    end
  end

  def stats
    @classes = 'home admin'
    @config = { :state => 'page' }.to_json
    
    if params[:format] == 'json'
      render :json => { :users => User.all.count, :matches => Match.all.count }
    else
    
      @users = User.all.map do |user|
        votes = user.feedback.count
        comments = user.feedback.reject{ |f| f.comment.nil? || f.comment.empty? }.count
        popularity = user.feedback.map { |f| f.cached_votes_total }.sum
      
      
        friends = !user.fb_friends.nil? ? user.fb_friends.split(',').count : 0
        pages = !user.pages.nil?
        profile = user.profile != '/'+user.to_url
        header = user.header.to_s.index("/headers/original/missing.png").nil?
      
        { 
          :last_sign_in => user.last_sign_in_at, 
          :sign_in_count => user.sign_in_count, 
          :popularity => popularity,
          :created_at => user.created_at,
          :friends => friends,
          :votes => votes,
          :comments => comments,
          :pages => pages,
          :profile => profile,
          :header => header
        }
      end
    
      @matches = Match.all.map{ |m| m.data.select{ |d| d.length == 2 }.first  }
      @states = Choice.states
      @states.shift
      @stateAbvs = Choice.stateAbvs
      @stateAbvs.shift
      @matchStates = []
      n = 0
      @stateAbvs.each do |state|
        count = @matches.select{ |match| match == state }.count
        @matchStates.push( { :count => count, :state => @states[n] } ) unless count == 0
        n+=1
      end
    end

  end
  
  def about
    @classes = 'home msg'
    @config = { :state => 'page' }.to_json
    @title = 'About'
    @content = <<EOF
         <h1>About november6th.org</h1>
         <p>november6th.org is the 100% social voter guide brought to you by the <a href='http://www.theleague.com/splash'>League of Young Voters</a>, <a href='http://www.neweracolorado.org'>New Era Colorado</a>, <a href='http://forwardmontana.org'>Forward Montana</a>, and the <a href='http://busproject.org'>Bus Project</a>.</p>
         <p>Some cool stuff about november6th.org:</p>
         <ul>
          <li>This is a crowdsourced voter guide. The content and order in which it appears is determined by the wisdom of the masses, not by political powerbrokers.</li>
          <li>This is open-source software. Our commitment to crowdsourcing doesn't stop with ballot measures. We've built this software open source so that others can modify and improve it. Want to check it out? <a href='http://github.com/busproject/ballot' target='_blank'>Here's our GitHub repo</a> - fork away! Want to help? Let us know.</li> 
          <li>We're also utilizing and supporting the Voter Information Project so that other similar projects can piece together the relevant and accurate ballot information for free.</li>
          <!--<li>For the latest updates on new features, please <a class="link" target='_blank' href="http://theballot.tumblr.com/">visit our Tumblr</a>.</li>-->
         </ul>
         <a class='about-button' href='/'>Find Your Ballot</a>

         <h1>Who We Are</h1>
         <p><strong><a href="http://twitter.com/mojowen" target="_blank">Scott Duncombe</a>, Developer</strong></p>
         <!--<p>Scott Duncombe is a native Oregonian, who grew up mostly in Corvallis before going to school at the University of Chicago, studying Chemistry and Political Science. He got involved with democracy and technology while working with the Student Government, eventually becoming the Student Body President. After Chicago, he organized for Obama for America before returning to Oregon, eventually joining the Bus Project to manage technology. The Federation stole him a year later. He also moonlights as a developer for candidates and others.</p>-->
         <p><strong><a href="https://twitter.com/noahmanger" target="_blank">Noah Manger</a>, Designer</strong></p>
         <!--<p>Text about Noah</p>-->
         <p><strong><a href="https://twitter.com/notsterno" target="_blank">Sarah Stern</a></strong></p>
         <!--<p>Sarah bio</p>-->
         <p><strong><a href="https://twitter.com/sampatton" target="_blank">Sam Patton</a></strong></p>
         <p><strong><a href="https://twitter.com/mattsinger7" target="_blank">Matt Singer</a></strong></p>
         <!--<p>Matt Bio</p>-->         
EOF

    render 'home/show'
  end
  
  
  def search
    prepped = '%'+params[:term].split(' ').map{ |word| word.downcase }.join(' ')+'%'
    results = []

    # Stripping profile down to it's root and converting to base 16 to convert into ID. If the base 16 doesn't match the search term - ignore it
    id = params[:term].gsub(ENV['BASE'],'').gsub(root_path,'').to_i(16).to_s(16) == params[:term].gsub(ENV['BASE'],'').gsub(root_path,'') ? params[:term].gsub(ENV['BASE'],'').gsub(root_path,'').to_i(16).to_s(10).to_i(2).to_s(10) : 0

    if params[:filter]
      results += User.where( "id = ? OR profile = ?", id, params[:term] ).limit(20).map{ |user| {:label => user.name, :url => ENV['BASE']+user.profile } } if params[:filter] == 'profile'
    else
      prepped = '%'+params[:term].split(' ').map{ |word| word.downcase }.join(' ')+'%'
      results = []
      results += User.where( "deactivated = ? AND banned = ? AND (lower(name) LIKE ? OR lower(last_name) LIKE ? OR lower(first_name) LIKE ? OR id = ?)",false,false, prepped, prepped, prepped, id ).limit(20).map{ |user| {:label => user.name, :url => ENV['BASE']+user.profile } }
      results += Choice.where( "lower(contest) LIKE ?", prepped).limit(20).map{ |choice| {:label => choice.contest+' ('+choice.geographyNice+')', :url => ENV['BASE']+'/'+choice.to_url } }
      results += Option.where( 'lower(name) LIKE ?',prepped).limit(20).map{ |option| { :label => option.name+' ('+option.choice.geographyNice+')', :url => ENV['BASE']+'/'+option.choice.to_url } }
    end
    render :json => results
  end

    def privacy
       @classes = 'home msg'
       @config = { :state => 'page' }.to_json
       @title = 'About'
       @content = <<EOF
       <h1>Privacy Policy</h1>
       <p>The League of Young Voters Education Fund and The Bus Federation Civic Fund (collectively, "we" or "us") are committed to preserving your privacy and safeguarding the personal and/or sensitive information you provide to us via any of our websites. This commitment is demonstrated by the terms of this Privacy Policy.</p>
       <p>We reserve the right to modify this Privacy Policy from time to time. The date of the latest revision will be listed at the bottom of the Policy. We encourage you to check this page each time you visit one of our websites so that you will know if the Policy has changed since you last visited the site. Your use of our websites indicates your acceptance to be bound by the terms of the Privacy Policy in effect as of the date of your use. If you do not agree to be bound by the terms of the Privacy Policy, do not use our websites.</p>

       <h1>Our Collection of Personal information</h1>

       <p>We do not collect personally identifiable information about individual users unless a user voluntarily provides such information to us, either directly or by agreeing to the terms and conditions if logging onto one of our sites through Facebook. We store any information that you provide, such as your name, mailing address or email address, using secure servers. We may share your information with third party vendors who use your information for the sole purpose of fulfilling your request (e.g., charging your donation). Each of our vendors has agreed to keep your information confidential from disclosure to others. We may also share your information between ourselves (in other words, between The League of Young Voters Education Fund or The Bus Federation Civic Fund). We may share anonymized information with independent researchers to better understand how people use this site. In addition, we will cooperate with law enforcement, which may include disclosing some of your personal information if necessary. We will never sell any of your personal information to any third party. And we will never post any of your personal information online without your consent.</p>

       <h1>Use of Cookies</h1>

       <p>"Cookies" are small text files that facilitate a user's access to and use of a website and allow a website operator to track usage and behavior with respect to its sites. We use cookies that automatically collect certain non-personal information about visitors to our websites. In addition, we use Google Analytics, which provides us with information about our users. We collect this information on an aggregate basis, which allows us to improve our websites to make them more useful to our users. We do not use any of this information on an individual basis.</p>

       <h1>Protecting Children's Privacy</h1>

       <p>We are concerned about the safety and privacy of children online. Therefore, we do not and will not knowingly contact or collect personal information from children under 13. It remains possible, however, that we may receive information given to us by or pertaining to children under 13. If we are notified of this, we will promptly delete the information from our servers. If you want to notify us of our receipt of information by or about any child under 13, please email us at <a href="mailto: info@november6th.org">info@november6th.org</a>.</p>

       <h1>Security</h1>

       <p>You may be able to purchase items or donate money via our websites using PayPal. PayPal does not provide us with your personal financial information (e.g., credit card number).</p>
       <p>We make every effort to ensure the secure collection and transmission of your sensitive information using industry accepted data collection and encryption methodologies, such as SSL (Secure Sockets Layer). We also have security measures in place to help protect against the loss, misuse or alteration of information within our control. Only employees with a need to know certain information to perform a specific task are granted access to personally identifiable information of our users. In addition, the servers that store sensitive information are kept in a secure environment.</p>

       <h1>Emails</h1>

       <p>You may sign up to receive email communications from us. These emails provide information that we think will be of interest to you, for example, information about new features or content on our sites, or calls for action on certain issues. If you provide us with your email address through some other action on one of our websites, we may add you to your email distribution list. You can always "opt out" of receiving our online communications by following the unsubscribe directions on any of the emails, or by sending us an email at <a href="mailto:info@november6th.org">info@november6th.org</a> asking that we delete you from our email list.</p>

       <p>Please recognize that emails are not secure against interception. Therefore, please do not send us sensitive or personal information via email.</p>

       <p>Links to Other Websites</h1>

       <p>We may provide links to other sites from our websites. We are not responsible for the privacy policies or the content on such sites. You should read the privacy policy of each website that you visit. This Privacy Policy applies only to information that we collect through our websites.</p>

       <h1>Questions?</h1>

       <p>If you have any questions about this Privacy Policy or any of our websites, please contact us at:</p>

       <p>The League of Young Voters Education Fund<br />
       540 President Street, 3rd Floor<br />
       Brooklyn, NY 11215<br />
       (347) 464-8683<br />
       <a href="mailto:info@november6th.org">info@november6th.org</a></p>


       <p>Last updated: October 5th, 2012</p>

EOF
      render 'home/show'
    end
    def tos
       @classes = 'home msg'
       @config = { :state => 'page' }.to_json
       @title = 'About'
       @content = <<EOF
       <h1>Terms of Use</h1>
       
       <p>Your use of any of the websites owned and operated by The League of Young Voters Education Fund or The Bus Federation Civic Fund (collectively, "we" or "us") is governed by these Terms of Use. We may modify these Terms of Use from time to time, so we encourage you to check this page each time you revisit one of our websites. The date of the latest revision will be listed below so you will know if the terms have changed since you last accessed the site. Your use of our websites indicates your acceptance to be bound by the provisions of the Terms of Use in effect as of the date of your use. If you do not accept these terms, do not use our websites.</p>
        
       <h1>Intellectual Property Rights</h1>

       <p>Our websites are protected by U.S. copyright laws and no portion of the sites may be reproduced or distributed without the permission of the applicable copyright owner. We maintain ownership rights in our trade names and other trademarks and service marks. Marks of third parties belong to their rightful owners.</p>

       <h1>Restrictions on Your Use of the Site</h1>

       <p>You may not use any of our websites (a) in violation of any applicable law or regulation, (b) in a manner that will infringe the copyright, trademark, trade secret or other intellectual property rights of others, (c) in a manner that will violate the privacy, publicity or other personal rights of others or reveal confidential information without permission, (d) in a manner that is profane, defamatory, violent, obscene, threatening, abusive, hateful, inflammatory or otherwise objectionable under common standards of decency, or (e) to comment on political candidates or parties.</p>

       <p>You also are prohibited from violating or attempting to violate the security of any of our websites, including, without limitation, the following activities: (a) attempting to probe, scan or test the vulnerability of a system or network or to breach security or authentication measures without proper authorization; (b) attempting to interfere with communication to any user, host or network, including, without limitation, via means of submitting a virus to the website, overloading, "flooding," "spamming," "mailbombing" or "crashing"; or (c) solicitation or advertisement. Violations of system or network security may result in civil or criminal liability. We will investigate occurrences that may involve such violations and may involve, and cooperate with, law enforcement authorities in prosecuting users who are involved in such violations.</p>

       <h1>Use of Comments</h1>

       <p>Users who log onto our websites through Facebook will be able to post comments on some of our sites. By posting any comments, you agree that these comments may be used by us for any purpose in any form without any additional permission from you and without any consideration apart from your participation on the website. By providing a comment to one of our sites, you are: (a) giving us a worldwide, non-exclusive right to use your name and/or user name, as well as any additional information you may have provided, in any material prepared by or for us in any form or media, now known or hereafter devised, in all languages throughout the world; (b) giving us a worldwide, non-exclusive, royalty-free, sublicenseable and transferable license to use, reproduce, distribute, prepare derivative works of and display your comments on our websites and in connection with other activities in any form or media, now known or hereafter devised, in all languages throughout the world; (c) agreeing and representing that you have not submitted material that (i) violates copyright, trademark, trade secret, or other intellectual property rights of others; (ii) violates the privacy, publicity or other personal rights of others; (iii) reveals confidential information; (iv) is profane, defamatory, violent, obscene, threatening, abusive, hateful, inflammatory or otherwise objectionable under standards of common decency; or (v) comments on political candidates or parties; (d) representing and warranting that you own or have the necessary licenses, rights, consents and permissions to use and authorize us to use all patent, trademark, trade-secret, copyright or other proprietary rights in and to any and all comments in the manner contemplated by these Terms of Use. We reserve the right not to post comments and to remove comments without prior notice, in our sole discretion.</p>

       <h1>Reservation of Rights</h1>

       <p>We reserve the right in our sole discretion to change, suspend or discontinue any or all aspects of any of our websites at any time without prior notice or liability. We also reserve the right in our sole discretion to suspend or terminate any user's rights to use our websites.</p>

       <h1>Disclaimer of Warranty</h1>

       <p>We do not warrant that our websites will operate error-free or that the servers are free of computer viruses or other harmful mechanisms. If your use of any of our websites results in the need for servicing or replacing equipment or data, we are not responsible for those costs. In no event shall we be liable for any damages whatsoever (including, without limitation, incidental and consequential damages, lost profits or damages resulting from lost data or business interruption) resulting from the use or inability to use our websites, whether based on warranty, contract, tort or any other legal theory, and whether or not we are advised of the possibility of such damages. to the fullest extent permitted by law, WE disclaim all warranties, whether express or implied, in connection with OUR websites and your use thereof. We make no warranties or representations about the accuracy or completeness of the content on our websites or the content on any third party sites linked to any of our websites. Furthermore, we assume no liability or responsibility for any direct or indirect, incidental, special, punitive, or consequential damages whatsoever resulting from any (1) errors, mistakes or inaccuracies of content, (2) personal injury or property damage of any nature whatsoever resulting from your access to or use of our websites, (3) any unauthorized access to or use of our secure servers and/or any and all personal information and/or financial information stored therein, (4) any interruption or cessation of transmission to or from any of our websites, (5) any bugs, viruses, Trojan horses or the like, which may be transmitted to or through any of our websites by any third party, and/or (6) any errors or omissions in any content or for any loss or damage of any kind incurred as a result of the use of any content posted, e-mailed, transmitted or otherwise made available via any of our websites. We shall not be liable for user submissions or the defamatory, offensive or illegal conduct of any third party and the risk of harm or damage from the foregoing rests entirely with you.</p>

       <h1>Indemnity</h1>

       <p>You agree to defend, indemnify and hold harmless The League of Young Voters Education Fund or The Bus Federation Civic Fund, their parents, subsidiaries and affiliated organizations, and the officers, directors, employees, members, shareholders, partners, licensees and agents of each of these, from and against any and all claims, damages, obligations, losses, liabilities, costs or debt and expenses (including but not limited to attorney's fees) arising from your use of any of our websites in violation of any term of these Terms of Use.</p>

       <h1>Claims of Copyright Infringement</h1>

       <p>We respect the intellectual property rights of others. If you believe that any material on one of our websites violates your intellectual property rights, please provide us with written notice that includes the following information:</p>
       <ul>
         <li>A description of the copyrighted work or other intellectual property that you claim has been infringed;</li>
         <li>A description of where the material that you claim is infringing is located on which website;</li>
         <li>Your address, telephone number and email address;</li>
         <li>A statement that you have a good faith belief that the disputed use is not authorized by the copyright owner, its agent or the law;</li>
         <li>A statement by you, made under penalty of perjury, that the information in your notice is accurate and that you are the copyright or intellectual property owner or are authorized to act on behalf of the copyright or intellectual property owner; and</li>
         <li>Your electronic or physical signature.</li>
       </ul>

       <p>Please address your letter as follows:</p>

       <p>The League of Young Voters Education Fund
       540 President Street, 3rd Floor<br />
       Brooklyn, NY 11215</p>

       <h1>General</h1>

       <p>By using our websites, you agree that you are of sufficient legal age in your jurisdiction to create binding legal obligations. The policies on our websites shall be governed by the laws of New York, without regard to its conflict of law rules. Any and all disputes arising out of or related to our websites shall be submitted to arbitration in New York, pursuant to the rules of the American Arbitration Association. If we are required to go to court, rather than arbitration, to enforce any of our rights, you agree to reimburse us for our legal costs and expenses if we are the prevailing party. Our failure to insist upon or to enforce strict performance of any provision of the policies on our websites shall not be construed as a waiver of any right. If any provision of any of the policies on any of our websites are determined by a court of competent jurisdiction to be invalid or unenforceable, such provision shall be replaced with a provision that complies with applicable law and best reflects the intentions of the parties.</p>

       <p>If you have any questions about this Privacy Policy or any of our websites, please contact us at:</p>

       <p>The League of Young Voters Education Fund<br />
       540 President Street, 3rd Floor<br />
       Brooklyn, NY 11215<br />
       (347) 464-8683<br />
       <a href="mailto:info@november6th.org">info@november6th.org</a></p>


       <p>Last updated: October 9th, 2012</p>

EOF
      render 'home/show'
    end

  
  def sitemap
    stateAbvs = Choice.stateAbvs
    newwest_user = User.all( :order => 'updated_at DESC', :limit => 1, :conditions => ['banned = ? AND deactivated = ?',false,false] ).first.updated_at.to_date
    
    @urls = [
        { :url => ENV['BASE']+'/about', :updated => 'Thu, 04 Oct 2012'},
        { :url => ENV['BASE']+'/guides', :updated => newwest_user  }
      ]
    @urls += (1..50).map{ |i| {:url => ENV['BASE']+'/'+stateAbvs[i], :updated => Choice.where('geography LIKE ?',stateAbvs[i]+'%').order('updated_at DESC').limit(1).first.updated_at.to_date } }

    @urls += User.active.map do |user| 
      updated = user.updated_at > user.feedback.most_recent.updated_at ? user.updated_at : user.feedback.order('updated_at DESC').limit(1).first.updated_at
      { :url => ENV['BASE']+'/'+user.profile.gsub('/','') , :updated => updated.to_date  }
    end

    @urls += Choice.all.map{ |c| { :url => c.to_url, :updated => c.updated_at.to_date } } 
    
    if params[:format]
      render :json => @urls.count 
    else
      render :template => 'home/sitemap'
    end
  end  

end
