class CreatePatients < ActiveRecord::Migration[7.0]
  def change
    create_table :patients, id: false do |t|
      t.string :upi, null: false
      t.references :person, null: false, foreign_key: true, primary_key: true
      t.references :doctor, foreign_key: { primary_key: :person_id }
      t.check_constraint "upi::text ~ '^[a-z0-9]{18}$'::text", name: 'upi_check'
      t.index :upi, name: 'check_upi_unique', unique: true
      t.check_constraint 'doctor_id <> person_id', name: 'check_if_dr_and_person_are_different'

      t.timestamps
    end
  end
end
