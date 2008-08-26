ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # member functions
  map.connect 'login',                          :controller => 'members/auth', :action => 'login'
  map.connect 'logout',                         :controller => 'members/auth', :action => 'logout'
  map.connect 'member/process_login',           :controller => 'members/auth', :action => 'process_login'
  map.connect 'member/restore_request',         :controller => 'members/auth', :action => 'restore_request'
  map.connect 'member/:action/:id',             :controller => 'members/account', :action => 'index'
    
  # management
  map.connect 'manage',                         :controller => 'management/default'
  map.connect 'manage/login',                   :controller => 'management/user',    :action => 'login'
  map.connect 'manage/logout',                  :controller => 'management/user',    :action => 'logout'
  map.connect 'manage/user/:action/:id',        :controller => 'management/user'
  map.connect 'manage/users/:action/:id',       :controller => 'management/users'
  
  # static content
  map.connect '*content_path',                  :controller => 'cms/content', :action => 'show'
end
