ENV['RAILS_SITE'] = File.basename(File.expand_path(File.join(File.dirname(__FILE__), '..')))

if !defined?(RAILS_ROOT)
  require File.dirname(__FILE__) + "/../../../config/environment" 
else
  #
  # put any custom config here
  #
  
end
