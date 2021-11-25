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

ActiveRecord::Schema.define(version: 2021_11_25_104451) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "line1"
    t.string "line2"
    t.string "line3"
    t.string "zipcode"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "addressable_type", null: false
    t.bigint "addressable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "clinics", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_clinics_on_organization_id"
  end

  create_table "credentials", force: :cascade do |t|
    t.integer "type"
    t.string "name"
    t.text "description"
    t.boolean "lifetime"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "funding_sources", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.bigint "admin_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["admin_id"], name: "index_organizations_on_admin_id"
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.integer "phone_type"
    t.string "number"
    t.string "phoneable_type", null: false
    t.bigint "phoneable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["phoneable_type", "phoneable_id"], name: "index_phone_numbers_on_phoneable"
  end

  create_table "qualifications", force: :cascade do |t|
    t.bigint "staff_id", null: false
    t.date "tb_cleared_at"
    t.date "doj_cleared_at"
    t.date "fbi_cleared_at"
    t.date "tb_expires_at"
    t.date "doj_expires_at"
    t.date "fbi_expires_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["staff_id"], name: "index_qualifications_on_staff_id"
  end

  create_table "qualifications_credentials", force: :cascade do |t|
    t.bigint "qualification_id", null: false
    t.bigint "credential_id", null: false
    t.date "issued_at"
    t.date "expires_at"
    t.string "cert_lic_number"
    t.text "documentation_notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["credential_id"], name: "index_qualifications_credentials_on_credential_id"
    t.index ["qualification_id"], name: "index_qualifications_credentials_on_qualification_id"
  end

  create_table "qualifications_funding_sources", force: :cascade do |t|
    t.bigint "qualification_id", null: false
    t.bigint "funding_source_id", null: false
    t.integer "type"
    t.string "data_filed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["funding_source_id"], name: "index_qualifications_funding_sources_on_funding_source_id"
    t.index ["qualification_id"], name: "index_qualifications_funding_sources_on_qualification_id"
  end

  create_table "rbt_supervisions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "status"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_rbt_supervisions_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.integer "status"
    t.integer "default_pay_code"
    t.integer "category"
    t.string "display_pay_code"
    t.integer "tracking_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.integer "department"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "user_services", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["service_id"], name: "index_user_services_on_service_id"
    t.index ["user_id"], name: "index_user_services_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.bigint "clinic_id"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "gender", default: 0
    t.bigint "supervisor_id"
    t.date "hired_at"
    t.text "web_address"
    t.integer "status", default: 0
    t.date "terminated_at"
    t.integer "pay_type"
    t.boolean "service_provider", default: false
    t.integer "timing_type"
    t.integer "hours_per_week"
    t.boolean "ot_exempt", default: false
    t.string "phone_ext"
    t.integer "term_type"
    t.integer "residency"
    t.date "status_date"
    t.string "driving_license"
    t.date "driving_license_expires_at"
    t.date "date_of_birth"
    t.string "ssn"
    t.string "badge_id"
    t.integer "badge_type"
    t.json "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clinic_id"], name: "index_users_on_clinic_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["supervisor_id"], name: "index_users_on_supervisor_id"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "clinics", "organizations"
  add_foreign_key "organizations", "users", column: "admin_id"
  add_foreign_key "qualifications", "users", column: "staff_id"
  add_foreign_key "qualifications_credentials", "credentials"
  add_foreign_key "qualifications_credentials", "qualifications"
  add_foreign_key "qualifications_funding_sources", "funding_sources"
  add_foreign_key "qualifications_funding_sources", "qualifications"
  add_foreign_key "rbt_supervisions", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "user_services", "services"
  add_foreign_key "user_services", "users"
  add_foreign_key "users", "users", column: "supervisor_id"
end
