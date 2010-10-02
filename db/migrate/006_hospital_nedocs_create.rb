class HospitalNedocsCreate < ActiveRecord::Migration
  def self.up
    create_table :nedocs do |t|
      t.column  :user_id, :int
      t.column  :number_ed_beds, :int,  :null => false
      t.column  :number_hospital_beds, :int,  :null => false
      t.column  :total_patients_ed, :int, :null => false
      t.column  :total_respirators, :int, :null => false
      t.column  :longest_admit, :decimal, :null => false
      t.column  :total_admits, :int,  :null => false
      t.column  :last_patient_wait, :decimal, :null => false
      t.column  :nedocs_score, :int
      t.column  :created_at, :timestamp
      t.column  :updated_at, :timestamp
    end
  end

  def self.down
    drop_table :nedocs
  end
end
