class UsersAddNotification < HospitalMigration
  def self.up
    add_column :users, :notify, :integer, :default => 1, :null => false
    add_column :users, :notify_threshold, :integer, :default => 200, :null => false
    add_column :users, :notify_address, :string
  end
  
  def self.down
    remove_column :users, :notify
    remove_column :users, :notify_threshold
    remove_column :users, :notify_address
  end
  
end
