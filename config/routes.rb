ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # client gateway
  map.connect '',                                     :controller => 'nedocs'
  map.connect 'nedocs',                               :controller => 'nedocs'
  map.connect 'user',                                 :controller => 'user'

  # Rails default
  map.connect ':controller/:action/:id'
  
  # Static content (help files, etc.) or 404
  map.connect '*content_path',                    :controller => 'cms/content', :action => 'show'
end
