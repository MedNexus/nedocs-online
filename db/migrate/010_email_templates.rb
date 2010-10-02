class EmailTemplates < ActiveRecord::Migration

  def self.up
    create_table 'email_templates' do |t|
      t.column  :user_id,           :int
      t.column  :content_0,   :string
      t.column  :content_1,   :string
      t.column  :content_2,   :string
      t.column  :content_3,   :string
      t.column  :content_4,   :string
      t.column  :content_5,   :string
      t.column  :name,              :string
      t.column  :created_at,        :timestamp
      t.column  :updated_at,        :timestamp
    end
  end
  
  def self.down
    drop_table :email_templates
  end
  
end