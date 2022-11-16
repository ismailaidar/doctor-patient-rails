class CreatePeople < ActiveRecord::Migration[7.0]
  def change
    create_table :people do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.check_constraint "first_name::text <> '' ", name: "first_name_check"
      t.check_constraint "last_name::text <> '' ", name: "last_name_check"
      t.timestamps
    end
  end
end
