class SurgePlan < ActiveRecord::Base
  
  validates_presence_of [ :name, :plan ], :message => 'is required'
  validates_inclusion_of [:range_low, :range_high], :in => 0..200, :message => 'must be between 0 and 200'
  validates_uniqueness_of :name, :message => 'already in use'
  validates_numericality_of [:range_low, :range_high]
  
  def self.list
    SurgePlan.find(:all, :order => 'range_low, range_high, name')
  end
  
  def self.find_plans_by_score(s)
    SurgePlan.find(:all, :conditions => ["range_low <= #{s} and range_high >= #{s}"], :order => 'range_low, range_high')
  end
  
  def self.display_all_plans(nedocs)
    plans = self.find_plans_by_score(nedocs.nedocs_score)
    return nil if plans.size == 0
    str = ""
    plans.each do |x|
      str += x.display_plan
    end
    
    return str
  end
  
  def display_plan
    if auto_format == 1
      # auto format the surge plan
      str = "<b>#{name}</b><ol><li>" + plan.split("\n").join("</li><li>") + "</li></ol>"
    else
      return name + "\n" + plan
    end
  end
  
  protected
  def validate
    if range_low and range_high
      errors.add(:range_low, "must be less than high value") if range_low >= range_high
      errors.add(:range_high, "must be greater than low value") if range_low >= range_high
    end
  end
  
end