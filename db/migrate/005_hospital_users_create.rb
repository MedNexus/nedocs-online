class HospitalUsersCreate < ActiveRecord::Migration
  def self.up
    # users will hold employees for the studio
    create_table 'users' do |t|
      t.column 'username',          :string, :limit => 30, :null => false
      t.column 'password_hash',     :string, :limit => 100, :null => false
      
      t.column 'first_name',        :string, :limit => 100
      t.column 'last_name',         :string, :limit => 100
      
      t.column 'dynamic_fields',    :text
      
      t.column 'active',            :integer, :default => 1, :null => false
      t.column 'is_superuser',      :integer, :default => 0, :null => false
      
      t.column 'created_on',        :timestamp
      t.column 'updated_on',        :timestamp
      
      
      t.column 'deleted',           :integer, :default => 0, :null => false
      t.column 'deleted_on',        :datetime
    end
    add_index 'users', [ 'deleted' ]
    
    u = User.new
    u.username = 'admin'
    u.password = 'admin'
    u.first_name = 'Administrative'
    u.last_name = 'User'
    u.is_superuser = 1
    u.save
    
    # not sure if we'll use this, but it could allow
    # managers to manager their employees as a group
    # dictating en mass who has access to what
    create_table 'user_groups' do |t|
      t.column 'name',              :string, :limit => 50, :null => false
      t.column 'description',       :string, :limit => 255
      
      t.column 'created_on',        :timestamp
      t.column 'updated_on',        :timestamp
      
      
      t.column 'deleted',           :integer, :default => 0, :null => false
      t.column 'deleted_on',        :datetime
    end
    add_index 'user_groups', [ 'name' ], :name => 'UN_user_groups_name', :unique => true
    add_index 'user_groups', [ 'deleted' ]
    
    create_table 'user_group_memberships' do |t|
      t.column 'user_id',           :integer, :null => false
      t.column 'user_group_id',     :integer, :null => false
      t.column 'created_on',        :timestamp
    end
  end
  
  def self.down
    drop_table :user_group_memberships
    drop_table :user_groups
    drop_table :users
  end
end
