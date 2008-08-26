class System < MasterMigration
  def self.up
    create_table "settings" do |t|
      t.column "name",              :string, :null => false
      t.column "value",             :text

      t.column "created_on",        :timestamp
      t.column "updated_on",        :timestamp
    end
    add_index "settings", ["name"], :name => "UN_settings_name", :unique => true

    create_table "tasks" do |t|
      t.column "name",              :string, :null => false

      t.column "created_on",        :timestamp
      t.column "updated_on",        :timestamp
    end
    add_index "tasks", ["name"], :name => "UN_tasks_name", :unique => true
  end
  
  def self.down
    drop_table "tasks"
    drop_table "settings"
  end
end