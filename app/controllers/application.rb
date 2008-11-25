# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_edu.ucla.harbor-ucla.nedocs_session_id'
  
  def set_default_session_values
    session[:time_zone] ||= @settings[:time_zone]
    
    # set default expiration times
    session[:authenticated_expiration] = defined?(MemberSessionTimeout) ? MemberSessionTimeout : 60.minutes if RAILS_ENV == 'production'
    
    # set some environment variables that we can read in models
    ENV['RAILS_USER_ID'] = session[:user_id].to_s
  end
  
  def authenticate_user
    # if user is not logged in, record the current request and redirect
    if (!session[:authenticated])
      flash[:notice] = defined?(UnauthenticatedUserMessage) ? UnauthenticatedUserMessage : 'This is an admin-only function. To continue, please log in now.'
      return false
    end
    
    @user = User.find(session[:user_id])
    session[:user_is_superuser] = (@user.is_superuser == 1)
    @user
  end
  
  def login_required
    if authenticate_user
      return true
    end
    
    render :update do |page|
      page.replace_html 'updateForm', :partial => 'user/login'
    end
  end
  
  
end
