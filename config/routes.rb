ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # client gateway
  map.connect '',                                     :controller => 'nedocs'
  map.connect 'nedocs/:action/:id',                               :controller => 'nedocs'
  map.connect 'login',                       :controller => 'management/user', :action => 'login'
  map.connect 'logout',                      :controller => 'management/user', :action => 'logout'
  
  map.connect 'management/user/:action/:id',            :controller => 'management/user'

  # Rails default
  map.connect ':controller/:action/:id'
  
  # Static content (help files, etc.) or 404
  map.connect '*content_path',                    :controller => 'cms/content', :action => 'show'
end
