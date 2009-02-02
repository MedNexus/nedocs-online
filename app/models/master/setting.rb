class Master::Setting < ActiveRecord::Base
  connect_to_master
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
end
