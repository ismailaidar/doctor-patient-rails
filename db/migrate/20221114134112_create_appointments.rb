class CreateAppointments < ActiveRecord::Migration[7.0]
  def up
    create_table :appointments do |t|
      t.references :patient, null: false, foreign_key: { primary_key: :person_id }
      t.references :doctor, null: false, foreign_key: { primary_key: :person_id }
      t.integer :status, null: false, default: 0
      t.tstzrange :timerange, null: false
      t.check_constraint "doctor_id <> patient_id", name: "check_if_dr_and_patient_are_different"

      t.timestamps
    end
    execute <<-SQL
      CREATE EXTENSION btree_gist;
      
      ALTER TABLE appointments
      ADD CONSTRAINT timerange_exclude_no_overlap_doctor_id
      EXCLUDE USING GIST (timerange WITH &&, doctor_id with =),
                        
      ADD CONSTRAINT timerange_exclude_no_overlap_patient_id
      EXCLUDE USING GIST (timerange WITH &&, patient_id with =);
    SQL
  end


  def down
    drop_table :appointments
    execute 'DROP EXTENSION btree_gist';
  end
end
