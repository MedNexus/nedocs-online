ENV['RAILS_SITE'] = File.basename(File.expand_path(File.join(File.dirname(__FILE__), '..')))

if !(defined?(RAILS_ROOT) && defined?(SITE_ROOT))
  require File.dirname(__FILE__) + "/../../../config/environment" 
else
  #
  # general
  #
  UserRedirectAfterLogin = {:controller => "/nedocs", :action => "index" }
  UserSessionTimeout = 60.minutes
  
  # set up PATH so we can run stuff, like svnversion and java
  ENV['PATH'] ||= '/bin:/usr/bin:/usr/local/bin'
  
  FopPath = File.join(RAILS_ROOT, 'vendor', 'fop', 'fop-0.94')
  FopExec = File.join(RAILS_ROOT, 'vendor', 'fop', 'fop-0.94', 'fop')
  FopConf = File.join(RAILS_ROOT, 'vendor', 'fop', 'fop-0.94', 'conf', 'fop.xconf')
  
  SSL_REDIRECTS_ON = false
  
  ErrorEmailSender = 'noreply@nedocsonline.org'
  ErrorEmailRecipients = 'sabin+nedocs+error@sabindang.com'
  
  IgnoreFrameworkFiles = ['user']  
  
  @javascripts = ['DD_belatedPNG.js']
  build_number = 'Beta'
end
