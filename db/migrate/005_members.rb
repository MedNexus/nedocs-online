class Members < InstitutionMigration
  def self.up
    create_table "members" do |t|
      t.column "membername",        :string
      t.column "email_address",     :text
      t.column "password_hash",     :string, :limit => 100
      
      t.column "prefix",            :string, :limit => 50
      t.column "first_name",        :string, :limit => 100
      t.column "middle_name",       :string, :limit => 100
      t.column "last_name",         :string, :limit => 100
      t.column "suffix",            :string, :limit => 50
      t.column "gender",            :string, :limit => 20
      t.column "birthdate",         :datetime
      
      t.column "phone_number",      :string, :limit => 50
      t.column "fax_number",        :string, :limit => 50
      t.column "mobile_number",     :string, :limit => 50
      t.column "alt_phone_number",  :string, :limit => 50
      
      t.column "mru_billing_location_id", :integer, :references => nil
      t.column "mru_delivery_location_id", :integer, :references => nil
      
      t.column "active",            :integer, :default => 1, :null => false
      t.column "temporary",         :integer, :default => 1, :null => false
      
      t.column "created_on",        :timestamp
      t.column "updated_on",        :timestamp
    end
    add_index "members", ["membername"], :name => "UN_members_membername", :unique => true
    
    create_table "locations" do |t|
      t.column "member_id",         :integer
      
      t.column "name",              :string, :default => "Home", :null => false
      
      t.column "address1",          :string
      t.column "address2",          :string
      t.column "address3",          :string
      t.column "address4",          :string
      t.column "city",              :string
      t.column "state",             :string
      t.column "zip",               :string
      
      t.column "phone",             :string
      t.column "phone_alt1",        :string
      t.column "phone_alt2",        :string
      t.column "fax",               :string
      
      t.column "active",            :integer, :default => 1, :null => false
      
      t.column "created_on",        :timestamp
      t.column "updated_on",        :timestamp
    end
    # add these for production to be safe
    #add_foreign_key "members", ["mru_billing_location_id"], "locations", ["id"]
    #add_foreign_key "members", ["mru_delivery_location_id"], "locations", ["id"]
  end
  
  def self.down
    drop_table "locations"
    drop_table "members"
  end
end