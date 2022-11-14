class CreateAppointments < ActiveRecord::Migration[7.0]
  def up
    create_table :appointments do |t|
      t.references :patient, null: false, column: :person_id
      t.references :doctor, null: true, column: :person_id, primary_key: :person_id
      t.tstzrange :timerange, null: false
      t.check_constraint "doctor_id <> patient_id", name: "npi_check"

      t.timestamps
    end
    execute <<-SQL
      CREATE EXTENSION btree_gist;
      
      ALTER TABLE appointments
      ADD CONSTRAINT timerange_exclude_no_overlap_doctor_id
      EXCLUDE USING GIST (timerange WITH &&,
                        doctor_id with =),
      ADD CONSTRAINT timerange_exclude_no_overlap_patient_id
      EXCLUDE USING GIST (timerange WITH &&, 
              patient_id with =);
    SQL
  end

    
  def down
    drop_table :appointments
    execute 'DROP EXTENSION btree_gist';
  end
end
