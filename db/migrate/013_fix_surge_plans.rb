class FixSurgePlans < HospitalMigration
  
  def self.up
    execute 'alter table surge_plans modify plan varchar(65536)'
  end
  
  def self.down
  end
  
end