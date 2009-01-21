# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  prepend_before_filter :require_ssl
  before_filter :authenticate_user, :set_auth_timeout
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_edu.ucla.harbor-ucla.nedocs_session_id'
  
  def set_auth_timeout
    session[:user_authenticated_expiration] = defined?(UserSessionTimeout) ? UserSessionTimeout : 30.minutes if RAILS_ENV == 'production'
  end
  
  def set_default_session_values
    session[:time_zone] ||= @settings[:time_zone]
    
    # set default expiration times
    session[:authenticated_expiration] = defined?(MemberSessionTimeout) ? MemberSessionTimeout : 60.minutes if RAILS_ENV == 'production'
    
    # set some environment variables that we can read in models
    ENV['RAILS_USER_ID'] = session[:user_id].to_s
  end
 
  def authenticate_user
    
    # if user is not logged in, record the current request and redirect
    if (!session[:user_authenticated])
      if User.find(:all).size == 0
        logger.warn('WARNING: No Users in System')
        render 'management/user/no_users'
      else
        flash[:notice] = defined?(UnauthenticatedUserMessage) ? UnauthenticatedUserMessage : 'This is an admin-only function. To continue, please log in now.'
        save_user_request
        respond_to do |format|
          format.html { redirect_to :controller => 'management/user', :action => 'login' }
          format.js do
            session[:saved_user_params] = { :controller => '/management/user', :action => 'success_popup', :mode => 'popup' }
            render :update do |page|
              page << "open('#{url_for :controller => '/management/user', :action => 'login', :mode => 'popup'}', '_blank', 'width=500, height=400');"
            end
          end
        end
      end
      
      return false
    end
    
    @user = User.find(session[:user_id])
    session[:user_is_superuser] = (@user.is_superuser == 1)
    @user
  end
   
  
  
end
