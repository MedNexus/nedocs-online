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
  def client_gateway_url
    return "http://" + self.key + ".hospitalphotosonline.com/"
  end
  
  # should be moved to settings
  def logo_file
    File.join(SITE_ROOT,'public','images','logos', self.key + ".gif")
  end
  
  # should be moved to settings
  def watermark_file
    file = File.join(SITE_ROOT, 'public', 'images', 'logos', self.key + "-watermark.png")
    return file if File.exists?(file)
    
    # otherwise, use default
    File.join(SITE_ROOT, 'public', 'images', 'interface', 'watermark.png')
  end
  
  def storage_used
    ActiveRecord::Base.connect_to_hospital(self.key)
    return (Image.sum('file_size').to_i + ImageVersion.sum('file_size').to_i)  || 0
  end
  
  def plugins
    plugins_search = case
      when self.key =~ /^test/ then File.join(SITE_ROOT, 'vendor', 'plugins', '*')
      else File.join(SITE_ROOT, 'vendor', 'plugins', "#{self.key}_*")
    end
    plugins = Dir["#{plugins_search}"].map { |plugin| File.basename(plugin) }
  end
  
  def set_up_ftp(password, max_bw = 0)
    self.ftp_home = "/tmp/ftp/#{self.code}"
    self.ftp_password = password
    self.ftp_max_bandwidth_kbyte = max_bw
    self.save
  end
end
