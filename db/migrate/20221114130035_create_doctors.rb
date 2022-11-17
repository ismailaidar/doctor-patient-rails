class CreateDoctors < ActiveRecord::Migration[7.0]
  def change
    create_table :doctors, id: false do |t|
      t.string :npi, null: false, index: { unique: true }
      t.integer :status, default: 0
      t.references :person, null: false, foreign_key: true, primary_key: true
      t.check_constraint "npi::text ~ '^[0-9]{10}$'::text", name: "npi_check"

      t.timestamps
    end
  end
end
