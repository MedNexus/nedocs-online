ENV['RAILS_SITE'] = File.basename(File.expand_path(File.join(File.dirname(__FILE__), '..')))

if !(defined?(RAILS_ROOT) && defined?(SITE_ROOT))
  require File.dirname(__FILE__) + "/../../../config/environment" 
else
  #
  # general
  #
  
  UserSessionTimeout = 60.minutes
  
  # completely override these framework-level files (generally models)
  IgnoreFrameworkFiles = [ 'location', 'product', 'order_line', 'payment' ]
  
  # set up PATH so we can run stuff, like svnversion and java
  ENV['PATH'] ||= '/bin:/usr/bin:/usr/local/bin'
  
  FopPath = File.join(RAILS_ROOT, 'vendor', 'fop', 'fop-0.94')
  FopExec = File.join(RAILS_ROOT, 'vendor', 'fop', 'fop-0.94', 'fop')
  FopConf = File.join(RAILS_ROOT, 'vendor', 'fop', 'fop-0.94', 'conf', 'fop.xconf')
  
  SSL_REDIRECTS_ON = true
  
  ErrorEmailSender = 'support@reflectconnect.com'
  ErrorEmailRecipients = 'support@reflectconnect.com'
  
  
  #
  # calendar
  #
  
  CalendarStartHour = 7
  CalendarEndHour = 21
  PixelsPerHour = 160
  
  
  #
  # clients/images
  #
  
  ThumbnailMaxWidth = 500
  
  DefaultImageDirectory = File.join(SITE_ROOT, 'tmp', 'images')
  CacheImageDirectory   = File.join(SITE_ROOT, 'tmp', 'image-cache')
  
  UseS3ImageStore = case RAILS_ENV
    when 'production' then true
    else false
  end
  
  AWS_ACCESS_KEY = "14SP7PZC6NYXVJ3FT1R2"
  AWS_SECRET_ACCESS_KEY = "Mpi+TLVoTUNzg12wpQpUsBkpHsqeX4N2p7pBH3ez"
  
  
  #
  # orders
  #
  
  OrderStatusCategories = [ 'Pre-Production', 'Production', 'Post-Production', 'Complete' ]
  
end
