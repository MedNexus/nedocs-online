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
    Setting.find_by_name('time_zone').value || "Pacific Time (US & Canada)" rescue "Pacific Time (US & Canada)"
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
  
  
  # Setup Hospital Specific Messages for a given score
  
  def self.level_0_instructions
    Setting.find_by_name('level_0_instructions').value rescue ""
  end
  
  def self.level_0_instructions=(val)
    update_setting('level_0_instructions', val)
  end
  
  def self.level_1_instructions
    Setting.find_by_name('level_1_instructions').value rescue ""
  end
  
  def self.level_1_instructions=(val)
    update_setting('level_1_instructions', val)
  end
  
  def self.level_2_instructions
    Setting.find_by_name('level_2_instructions').value rescue ""
  end
  
  def self.level_2_instructions=(val)
    update_setting('level_2_instructions', val)
  end
  
  def self.level_3_instructions
    Setting.find_by_name('level_3_instructions').value rescue ""
  end
  
  def self.level_3_instructions=(val)
    update_setting('level_3_instructions', val)
  end
  
  def self.level_4_instructions
    Setting.find_by_name('level_4_instructions').value rescue ""
  end
  
  def self.level_4_instructions=(val)
    update_setting('level_4_instructions', val)
  end
  
  def self.level_5_instructions
    Setting.find_by_name('level_5_instructions').value rescue ""
  end
  
  def self.level_5_instructions=(val)
    update_setting('level_5_instructions', val)
  end
  
  private
  def self.update_setting(key,val)
    s = Setting.find_or_create_by_name(key)
    s.value = val
    s.save
  end
    
end
