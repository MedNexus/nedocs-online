class Master::Hospital < ActiveRecord::Base
  connect_to_master
  acts_as_soft_deletable
  
  has_many :hosts, :class_name => 'HospitalHost', :foreign_key => 'hospital_id'
  
  def self.find_by_host(host)
    Master::HospitalHost.find_by_host(host).hospital rescue nil
  end
  
  def create_database(hospital_name)
    env = ENV['RAILS_ENV'] || 'development'
    if env == 'production'
      # run script/makedb #{hospital_name} production
    end
  end
    
  # should be moved to settings
  def logo_file
    File.join(SITE_ROOT,'public','images','logos', self.key + ".gif")
  end
  

end
