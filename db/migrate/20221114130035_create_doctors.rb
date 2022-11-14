class CreateDoctors < ActiveRecord::Migration[7.0]
  def change
    create_table :doctors, id: false do |t|
      t.string :npi, unique: true, null: false, index: true
      t.references :person, null: false, foreign_key: true, primary_key: true
      t.check_constraint "npi::text ~ '^[0-9]{10}$'::text", name: "npi_check"
      t.index :npi, name: 'check_npi_unique', unique: true

      t.timestamps
    end
  end
end
