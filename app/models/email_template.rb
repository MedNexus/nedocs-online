class EmailTemplate < ActiveRecord::Base
  belongs_to :user
  validates_presence_of [ :name, :content_0, :content_1, :content_2, :content_3, :content_4, :content_5 ], :message => 'is required'
  validates_uniqueness_of :name, :message => 'already in use'
  
  def before_destory
    if EmailTemplate.count <= 1 || self.id == 1
      errors.add_to_base "Cannot delete #{self.name.upcase} because it is the last template"
      return false
    else
      return true
    end
  end
  
  def self.list
    EmailTemplate.find(:all, :conditions => ["user_id is null"], :order => ["name"])
  end
  
  def content(level)
    return self["content_" + level.to_s]
  end
end