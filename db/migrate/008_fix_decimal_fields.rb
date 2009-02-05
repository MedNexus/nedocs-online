class FixDecimalFields < HospitalMigration
  def self.up
    execute 'alter table nedocs modify last_patient_wait decimal(8,3)'  
    execute 'alter table nedocs modify longest_admit decimal(8,3)'
  end
  
  def self.down
    # don't have to do anything
  end
  
end