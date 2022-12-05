class CreateDoctors < ActiveRecord::Migration[7.0]
  def up
    create_enum 'enum_status_doctor', %w[active inactive]
    create_table :doctors, id: false do |t|
      t.string :npi, null: false, index: { unique: true }
      t.enum :status, default: 'active', null: false, enum_type: 'enum_status_doctor'
      t.references :person, null: false, foreign_key: true, primary_key: true
      t.check_constraint "npi::text ~ '^[0-9]{10}$'::text", name: 'npi_check'

      t.timestamps
    end
  end

  def down
    drop_table :doctors
    execute 'DROP TYPE enum_status_doctor'
  end
end
