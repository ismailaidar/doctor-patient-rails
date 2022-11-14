class CreateDoctors < ActiveRecord::Migration[7.0]
  def change
    create_table :doctors, id: false do |t|
      t.string :npi, unique: true, null: false
      t.references :person, null: false, foreign_key: true, primary_key: true
    
      t.timestamps
    end
    reversible do |dir|
      dir.up do
        # add a CHECK constraint
        execute <<-SQL
          ALTER TABLE doctors
            ADD CONSTRAINT npi_check
              CHECK ( npi ~ '^[0-9]{10}$');
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE doctors
            DROP CONSTRAINT npi_check;
        SQL
      end
    end
  end
end
