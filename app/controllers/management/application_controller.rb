class Management::ApplicationController < ApplicationController
  layout 'application'
  before_filter :check_admin_rights
  
  def check_admin_rights
    unless session[:user_is_superuser]
      flash[:error] = "You must be an admin to access this area"
      redirect_to :controller => "/nedocs", :action => "index"
    end
  end
end
