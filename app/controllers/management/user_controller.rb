class Management::UserController < Management::ApplicationController
  layout 'application'
  
  def redirect_to_default(user)
    # redirect to the users desired default dashboard
    redirect_to UserRedirectAfterLogin and return if defined?(UserRedirectAfterLogin)
    redirect_to :controller => 'nedocs', :action => 'index'
  end
  
  def success_popup
    # render :layout => 'login'
  end
end
