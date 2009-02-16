class DropDynamicFields < HospitalMigration
  
  def self.up
    remove_column :users, :dynamic_fields
  end
  
  def self.down
    add_column :users, :dynamic_fields, :text
  end

end