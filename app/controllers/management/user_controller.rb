class Management::UserController < Management::ApplicationController
  skip_before_filter :check_admin_rights
  skip_before_filter :save_request
  skip_before_filter :authenticate_user, :only => [ :login, :process_login, :logout, :create_first, :process_create_first ]
  
  def redirect_to_default(user)
    # redirect to the users desired default dashboard
    redirect_to UserRedirectAfterLogin and return if defined?(UserRedirectAfterLogin)
  end
  
  def success_popup
    # render :layout => 'login'
  end

  # login page
  def login
    #authenticate_user if (::User.find_all.size == 0)
  end
  
  def process_login
    # run authentication code here
    test = ::User.find_by_username(params[:login][:username]) rescue nil
    if (test && test.password_hash == User.hash_password(params[:login][:password], test.password_hash[0,16]))
      if (test.active != 1)
        flash[:error] = 'Your account has been disabled by an administrator.'
        redirect_to :action => 'login' and return false
      end
      session[:user_authenticated] = true
      
      session[:user_id] = test.id
      session[:user_username] = test.username
      session[:user_first_name] = test.first_name
      session[:user_last_name] = test.last_name
      
      complete_login(test)
      
      if params[:redirect_on_success]
        redirect_to params[:redirect_on_success] and return
      else
        restore_request(test)
      end
    else
      flash[:error] = 'Invalid username or password, please try again.'
      redirect_to params[:redirect_on_failure] || { :action => 'login' }
    end
  end
  
  def complete_login(user)
  end
  
  def restore_request(user)
    # restore saved request params if they exist
    if session[:saved_user_params] && session[:saved_user_params].is_a?(Hash) &&
       ![ 'restore_request', 'login' ].include?(session[:saved_user_params][:action])
      p = session[:saved_user_params]
      session[:saved_user_params] = nil
      p[:controller] = '/' + p[:controller] if p[:controller].slice(0..0) != '/'
      redirect_to p
    else
      return redirect_to_default(user)
    end
  end
  
  def redirect_to_default(user)
    redirect_to UserRedirectAfterLogin and return if defined?(UserRedirectAfterLogin)
    redirect_to :controller => '/management/default', :action => 'index'
  end
  
  
  ###
  ### logout
  ###
  
  def logout
    complete_logout(::User.find_by_id(session[:user_id])) if session[:authenticated]
    reset_session
    cookies.delete(:user_auth_status)
    flash[:notice] = 'You have been logged out of the system.'
    redirect_to UserRedirectAfterLogout and return if defined?(UserRedirectAfterLogout)
    redirect_to params[:redirect] and return unless params[:redirect].empty?
    redirect_to :action => 'login'
  end
  
  def complete_logout(user)
  end
  
  
  ###
  ### update profile
  ###
  
  def profile
    @user = ::User.find(session[:user_id])
  end
  
  def process_profile
    @user = ::User.find(session[:user_id])
    @user.attributes = @user.attributes.update(params[:user])
    
    if (@user.save)
      flash[:notice] = 'Your profile has been updated.'
      redirect_to :action => 'profile' and return true
    end
    
    # if we ended up here, something went wrong... back to the reg page
    render :action => 'profile'
  end
  
  
  ###
  ### first time setup
  ###
  
  def create_first
    redirect_to :action => 'login' and return unless ::User.find_all_by_active(1).empty?
    @user = ::User.new
  end
  
  def process_create_first
    redirect_to :action => 'login' and return unless ::User.find_all_by_active(1).empty?
    
    @user = ::User.new(params[:user])
    
    @user.active = 1
    @user.is_superuser = 1
    
    if (@user.save)
      flash[:notice] = 'User created successfully. Please log in now.'
      redirect_to :controller => 'user', :action => 'login'
    else
      @errors = 'The following errors occurred:'
      for e in @user.errors.full_messages
        @errors << '<br/>' << e
      end
      render :action => 'create_first'
    end
  end  
end
