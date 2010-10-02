# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 13) do

  create_table "email_templates", :force => true do |t|
    t.integer  "user_id"
    t.string   "content_0"
    t.string   "content_1"
    t.string   "content_2"
    t.string   "content_3"
    t.string   "content_4"
    t.string   "content_5"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hospital_hosts", :force => true do |t|
    t.integer "hospital_id", :null => false
    t.string  "host",        :null => false
  end

  add_index "hospital_hosts", ["host"], :name => "UN_hospital_hosts_host", :unique => true

  create_table "hospitals", :force => true do |t|
    t.string   "name",                       :null => false
    t.string   "code",                       :null => false
    t.string   "key",                        :null => false
    t.integer  "active",      :default => 1, :null => false
    t.integer  "require_ssl", :default => 1, :null => false
    t.datetime "created_on"
    t.integer  "deleted",     :default => 0, :null => false
    t.datetime "deleted_on"
  end

  add_index "hospitals", ["code"], :name => "UN_hospitals_code", :unique => true
  add_index "hospitals", ["deleted"], :name => "index_hospitals_on_deleted"
  add_index "hospitals", ["key"], :name => "UN_hospitals_key", :unique => true

  create_table "nedocs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "number_ed_beds",                                     :null => false
    t.integer  "number_hospital_beds",                               :null => false
    t.integer  "total_patients_ed",                                  :null => false
    t.integer  "total_respirators",                                  :null => false
    t.decimal  "longest_admit",        :precision => 8, :scale => 3
    t.integer  "total_admits",                                       :null => false
    t.decimal  "last_patient_wait",    :precision => 8, :scale => 3
    t.integer  "nedocs_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "settings", :force => true do |t|
    t.string   "name",       :null => false
    t.text     "value"
    t.datetime "created_on"
    t.datetime "updated_on"
  end

  add_index "settings", ["name"], :name => "UN_settings_name", :unique => true

  create_table "surge_plans", :force => true do |t|
    t.string  "name",                                           :null => false
    t.integer "range_low",                                      :null => false
    t.integer "range_high",                                     :null => false
    t.text    "plan",        :limit => 16777215
    t.integer "auto_format",                     :default => 1, :null => false
  end

  create_table "user_group_memberships", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.integer  "user_group_id", :null => false
    t.datetime "created_on"
  end

  create_table "user_groups", :force => true do |t|
    t.string   "name",        :limit => 50,                :null => false
    t.string   "description"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "deleted",                   :default => 0, :null => false
    t.datetime "deleted_on"
  end

  add_index "user_groups", ["deleted"], :name => "index_user_groups_on_deleted"
  add_index "user_groups", ["name"], :name => "UN_user_groups_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "username",           :limit => 30,                   :null => false
    t.string   "password_hash",      :limit => 100,                  :null => false
    t.string   "first_name",         :limit => 100
    t.string   "last_name",          :limit => 100
    t.integer  "active",                            :default => 1,   :null => false
    t.integer  "is_superuser",                      :default => 0,   :null => false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "deleted",                           :default => 0,   :null => false
    t.datetime "deleted_on"
    t.integer  "send_notifications",                :default => 1,   :null => false
    t.integer  "notify_threshold",                  :default => 200, :null => false
    t.string   "notify_address"
    t.integer  "email_template_id"
  end

  add_index "users", ["deleted"], :name => "index_users_on_deleted"

end
