ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # util
  map.connect 'email_forms/:action/:id',        :controller => 'forms/email'
  map.date_picker 'util/date_picker',           :controller => 'util', :action => 'date_picker'
  
  # management
  map.connect 'manage',                         :controller => 'management/default'
  map.connect 'manage/login',                   :controller => 'management/user',    :action => 'login'
  map.connect 'manage/logout',                  :controller => 'management/user',    :action => 'logout'
  map.connect 'manage/user/:action/:id',        :controller => 'management/user'
  
  # put your routes here (no Rails default, so each controller needs its own route)
  
  # static content
  map.connect '*content_path',                  :controller => 'cms/content', :action => 'show'
end
