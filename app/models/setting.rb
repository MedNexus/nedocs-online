class Setting < ActiveRecord::Base
  
  # where do nedoc emails come from?
  def self.hospital_email_address
    Setting.find_by_name('hospital_email_address').value rescue "nedocs@nedocsonline.org"
  end
  
  def self.hospital_email_address=(val)
    s = Setting.find_or_create_by_name('hospital_email_address')
    s.value = val
    s.save
  end
  
  def self.time_zone=(val)
    s = Setting.find_or_create_by_name('time_zone')
    s.value = val
    s.save
  end
  
  def self.time_zone
    Setting.find_by_name('time_zone').value rescue "Pacific Time (US & Canada)"
  end
    
      
  def self.public_display?
    Setting.find_by_name('public_display_score').value == 'true' rescue false
  end
  
  def self.public_display=(val)
    s = Setting.find_or_create_by_name('public_display_score')
    s.value = val
    s.save
  end
  
  def self.number_of_hospital_beds
    Setting.find_by_name('number_of_hospital_beds').value rescue ''
  end
  
  def self.number_of_hospital_beds=(val)
    s = Setting.find_or_create_by_name('number_of_hospital_beds')
    s.value = val
    s.save
  end
  
  def self.number_of_ed_beds
    Setting.find_by_name('number_of_ed_beds').value rescue ''
  end
  
  def self.number_of_ed_beds=(val)
    s = Setting.find_or_create_by_name('number_of_ed_beds')
    s.value = val
    s.save
  end
  
  def self.confirmation_threshold
    Setting.find_by_name('confirmation_threshold').value.to_i rescue 180
  end
  
  def self.confirmation_threshold=(val)
    s = Setting.find_or_create_by_name('confirmation_threshold')
    s.value = val
    s.save
  end    
    
end
