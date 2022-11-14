class CreatePatients < ActiveRecord::Migration[7.0]
  def change
    create_table :patients, id: false do |t|
      t.string :upi, unique: true, null: false
      t.references :person, null: false, foreign_key: true, primary_key: true
      t.references :doctor, null: true
      t.check_constraint "upi::text ~ '^[a-z0-9]{18}$'::text", name: "npi_check"
      t.timestamps
    end

  end
end
