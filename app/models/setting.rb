class Setting < ActiveRecord::Base
  
  def self.public_display?
    Setting.find_by_name('public_display_score').value == 'true' rescue false
  end
  
  def self.number_of_hospital_beds
    Setting.find_by_name('number_of_hospital_beds').value rescue ''
  end
  
  def self.number_of_ed_beds
    Setting.find_by_name('number_of_ed_beds').value rescue ''
  end
    
    
end
