class Master::HospitalHost < ActiveRecord::Base
  connect_to_master
  belongs_to :hospital
end