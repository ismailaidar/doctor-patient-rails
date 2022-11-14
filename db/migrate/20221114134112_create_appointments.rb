class CreateAppointments < ActiveRecord::Migration[7.0]
  def change
    create_table :appointments do |t|
      t.references :patient, null: false, column: :person_id
      t.references :doctor, null: true, column: :person_id, primary_key: :person_id
      t.tstzrange :timerange, null: false
      t.check_constraint "doctor_id::integer <> patient_id::integer", name: "npi_check"

      t.timestamps
    end
    reversible do |dir|
      dir.up do
        # add a CHECK constraint
        execute <<-SQL
        CREATE EXTENSION btree_gist;
        ALTER TABLE IF EXISTS ONLY appointments
        ADD CONSTRAINT timerange_exclude_no_overlap_doctor_id
        EXCLUDE USING GIST (timerange WITH &&, -- && no overlap
                          doctor_id with =),
        ADD CONSTRAINT timerange_exclude_no_overlap_patient_id -- = if the Dr_id is identical the range must not overlap
        EXCLUDE USING GIST (timerange WITH &&, 
                patient_id with =);
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE IF EXISTS ONLY appointments
            DROP CONSTRAINT timerange_exclude_no_overlap_doctor_id,
            DROP CONSTRAINT timerange_exclude_no_overlap_patient_id; -- multi constraint in alter
          DROP EXTENSION btree_gist; -- after drop
        SQL
      end
    end
  end
end
