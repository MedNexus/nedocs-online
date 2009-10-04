ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # client gateway
  map.connect '',                                     :controller => 'nedocs'
  map.connect 'nedocs/:action/:id',                   :controller => 'nedocs'
  map.connect 'login',                                :controller => 'management/user', :action => 'login'
  map.connect 'logout',                               :controller => 'management/user', :action => 'logout'
  
  map.connect 'admin/user/:action/:id',           :controller => 'management/user'
  map.connect 'admin/users/:action/:id',          :controller => 'management/users'
  map.connect 'admin/settings/:action/:id',       :controller => 'management/settings'
  map.connect 'admin/email_templates/:action/:id',:controller => 'management/email_templates'
  map.connect 'admin/reports/:action/:id',        :controller => 'management/reports'
  map.connect 'admin/surgeplans/:action/:id',     :controller => 'management/surge_plans'
  map.connect 'admin/:action/:id',                :controller => 'management/admin'
  
  map.connect 'api/nedocs/:action/:id',           :controller => 'api/nedocs'

  # Rails default
  map.connect ':controller/:action/:id'
  
  # Static content (help files, etc.) or 404
  map.connect '*content_path',                    :controller => 'cms/content', :action => 'show'
end
