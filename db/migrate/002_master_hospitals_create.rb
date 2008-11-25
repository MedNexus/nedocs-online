class MasterHospitalsCreate < MasterMigration
  def self.up
    create_table 'hospitals' do |t|
      t.column 'name',              :string, :null => false
      t.column 'code',              :string, :null => false
      t.column 'key',               :string, :null => false
      
      t.column 'active',            :integer, :default => 1, :null => false
      t.column 'require_ssl',       :integer, :default => 1, :null => false
      
      t.column 'created_on',        :timestamp
      
      
      t.column 'deleted',           :integer, :default => 0, :null => false
      t.column 'deleted_on',        :datetime
      
    end
    add_index 'hospitals', [ 'deleted' ]
    add_index 'hospitals', [ 'code' ], :name => 'UN_hospitals_code', :unique => true
    add_index 'hospitals', [ 'key' ], :name => 'UN_hospitals_key', :unique => true
    
    # for additional domain names
    create_table 'hospital_hosts' do |t|
      t.column 'hospital_id',         :integer, :null => false
      t.column 'host',              :string, :null => false
    end
    add_index 'hospital_hosts', [ 'host' ], :name => 'UN_hospital_hosts_host', :unique => true

  end
  
  def self.down
    drop_table 'hospitals'
    drop_table 'hospital_hosts'
  end
end
