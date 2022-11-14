# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_11_14_134112) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigserial "doctor_id", null: false
    t.daterange "timerange", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id"], name: "index_appointments_on_doctor_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["timerange", "doctor_id"], name: "timerange_exclude_no_overlap_doctor_id", using: :gist
    t.index ["timerange", "patient_id"], name: "timerange_exclude_no_overlap_patient_id", using: :gist
    t.check_constraint "doctor_id <> patient_id", name: "check_doctor_and_patient_are_different_people"
  end

  create_table "doctors", primary_key: "person_id", force: :cascade do |t|
    t.string "npi", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_doctors_on_person_id"
    t.check_constraint "npi::text ~ '^[0-9]{10}$'::text", name: "npi_check"
  end

  create_table "patients", primary_key: "person_id", force: :cascade do |t|
    t.string "upi", null: false
    t.bigint "doctors_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctors_id"], name: "index_patients_on_doctors_id"
    t.index ["person_id"], name: "index_patients_on_person_id"
    t.check_constraint "upi::text ~ '^[a-z0-9]{18}*$'::text", name: "upi_check"
  end

  create_table "people", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "doctors", "people"
  add_foreign_key "patients", "people"
end
