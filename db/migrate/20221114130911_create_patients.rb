class CreatePatients < ActiveRecord::Migration[7.0]
  def change
    create_table :patients, id: false do |t|
      t.string :upi, unique: true, null: false
      t.references :person, null: false, foreign_key: true, primary_key: true
      t.references :doctors, null: true

      t.timestamps
    end
    reversible do |dir|
      dir.up do
        # add a CHECK constraint
        execute <<-SQL
          ALTER TABLE patients
            ADD CONSTRAINT upi_check
              CHECK ( upi ~ '^[a-z0-9]{18}*$');
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE patients
            DROP CONSTRAINT upi_check;
        SQL
      end
    end
  end
end
