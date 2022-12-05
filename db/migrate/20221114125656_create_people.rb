class CreatePeople < ActiveRecord::Migration[7.0]
  def change
    create_table :people do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.check_constraint "first_name ~ '\\S'"
      t.check_constraint "last_name ~ '\\S'"
      t.timestamps
    end
  end
end
