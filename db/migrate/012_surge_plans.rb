class SurgePlans < HospitalMigration
  
  def self.up
    create_table :surge_plans do |t|
      t.column  :name, :string, :limit => 255, :null => false
      t.column  :range_low, :int, :null => false
      t.column  :range_high, :int, :null => false
      t.column  :plan, :string, :limit => 1024
      t.column  :auto_format, :int, :default => 1, :null => false
    end
  end
  
  def self.down
    drop_table :surge_plans
  end
  
end