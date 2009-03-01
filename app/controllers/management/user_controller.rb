class Management::UserController < Management::ApplicationController
  skip_before_filter :check_admin_rights
  
  def redirect_to_default(user)
    # redirect to the users desired default dashboard
    redirect_to UserRedirectAfterLogin and return if defined?(UserRedirectAfterLogin)
  end
  
  def success_popup
    # render :layout => 'login'
  end
  
end
