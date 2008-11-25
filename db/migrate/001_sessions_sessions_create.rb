class SessionsSessionsCreate < SessionsMigration
  def self.up
    create_table 'sessions' do |t|
      t.column 'session_id',        :string, :references => nil
      t.column 'data',              :text
      t.column 'updated_at',        :datetime
    end
    
    add_index 'sessions', 'session_id'
  end
  
  def self.down
    drop_table 'sessions'
  end
end
