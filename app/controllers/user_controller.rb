class UserController < ApplicationController
  
  def index
    @item = User.new
    @active = User.find_all_by_active(1)
    @archived = User.find_all_by_active(0)
  end
  
  def new
  end
  
  def update
  end
  
  def process_login
    # first try to find member by membername
    test = User.find_by_username(params[:login][:username]) if params[:login]

    if (test && test.password_hash &&
        test.password_hash == User.hash_password(params[:login][:password], test.password_hash[0,16]))

      session[:authenticated] = true    
      session[:user_id] = test.id
      session[:user_first_name] = test.first_name
      session[:user_last_name] = test.last_name
      
      # store user_id so we can access it in models
      ENV['RAILS_USER_ID'] = session[:user_id].to_s
      flash[:error] = nil
      flash[:notice] = "You have been logged in"
      
      # display the form
      render :update do |page|
        page.replace_html 'updateForm', :partial => 'nedocs/form'
      end
    else
      flash[:error] = 'Invalid username or password, please try again.'
      
      # display the login screen
      render :update do |page|
        page.replace_html 'updateForm', :partial => 'user/login'
      end
    end
  end
  
  def logout
    session[:authenticated] = nil
    flash[:message] = 'Logged Out'
    redirect_to :controller => 'nedocs', :action => 'index'
  end
  
end
