class EmailTemplate < ActiveRecord::Base
  belongs_to :user
  validates_presence_of [ :name, :content_0, :content_1, :content_2, :content_3, :content_4, :content_5 ], :message => 'is required'
  validates_uniqueness_of :name, :message => 'already in use'
  
  def self.list
    EmailTemplate.find(:all, :conditions => ["user_id is null"], :order => ["name"])
  end
  
end