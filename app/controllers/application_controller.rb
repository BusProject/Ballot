class ApplicationController < ActionController::Base
  protect_from_forgery
 unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
 end
  
  private
    def render_404(exception)
      @not_found_path = exception.message
      @config = { :state => 'error' }.to_json
      @title = "Can't Find That!"
      @content = 
      "
        <script type='text/javascript'> $(document).ready( function() {
            $('.finder').betterAutocomplete( '/search', function( event, ui ) { document.location = '/'+ui.item.url } )
            $('.finder').bind('focus.down',function(e) { $(document).scrollTop( $(this).unbind('focus.down').position().top ) })
        })</script>
        <div class='big'>&#161;ERROR!</div>
        <h1>#message</h1>
        <br />
        <!--[if IE]><em>I'm sorry we couldn\'t find that for you, try searching maybe?</em><![endif]-->
        <input class='finder' placeholder=\"I'm sorry we couldn\'t find that for you, try searching maybe?\">
        
      "
      @classes = "msg home"
      @content = @content.gsub('#message',exception.to_s.split(' ').map{|w| w[0].upcase+w.slice(1,w.length)}.join(' '))

      respond_to do |format|
        format.html { render template: 'home/show', layout: 'layouts/application', status: 404 }
        format.all { render nothing: true, status: 404 }
      end
    end
    
end
