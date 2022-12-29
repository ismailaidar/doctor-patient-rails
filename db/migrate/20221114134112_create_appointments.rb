class CreateAppointments < ActiveRecord::Migration[7.0]
  def up
    create_enum 'enum_status_appointment', %w[ok error]
    create_table :appointments do |t|
      t.references :patient, null: false, foreign_key: { primary_key: :person_id, on_delete: :cascade }
      t.references :doctor, null: false, foreign_key: { primary_key: :person_id, on_delete: :cascade }
      t.enum :status, default: 'ok', null: false, enum_type: 'enum_status_appointment'
      t.tstzrange :timerange, null: false
      t.check_constraint "doctor_id <> patient_id OR status <> 'ok'", name: 'check_if_dr_and_patient_are_different'
      t.check_constraint 'NOT isempty(timerange)', name: 'check_if_empty'

      t.timestamps
    end
    execute <<-SQL
      CREATE EXTENSION btree_gist;

      ALTER TABLE appointments
      ADD CONSTRAINT index_appointments_timerange_exclude_no_overlap_doctor_id
      EXCLUDE USING GIST (timerange WITH &&, doctor_id with =) WHERE (status = 'ok'),
      ADD CONSTRAINT index_appointments_timerange_exclude_no_overlap_patient_id
      EXCLUDE USING GIST (timerange WITH &&, patient_id with =) WHERE (status = 'ok');

      CREATE UNIQUE INDEX index_unique_patient_doctor_timerange
      ON appointments (patient_id, doctor_id, timerange);
    SQL
  end

  def down
    drop_table :appointments
    execute 'DROP EXTENSION btree_gist'
    execute 'DROP TYPE enum_status_appointment'
  end
end
