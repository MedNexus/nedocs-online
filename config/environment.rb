# required to run under mongrel
ENV['RAILS_SITE'] = File.basename(File.expand_path(File.join(File.dirname(__FILE__), '..')))
require File.dirname(__FILE__) + "/../../../config/environment" unless defined?(RAILS_ROOT)

# Application Wide Variables Here