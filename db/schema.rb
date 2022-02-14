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

ActiveRecord::Schema.define(version: 2022_02_14_123311) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "line1"
    t.string "line2"
    t.string "line3"
    t.string "zipcode"
    t.string "city"
    t.string "state"
    t.string "country"
    t.integer "address_type", default: 0
    t.string "addressable_type", null: false
    t.bigint "addressable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["addressable_id", "addressable_type", "address_type"], name: "index_on_address", unique: true
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "attachments", force: :cascade do |t|
    t.string "category"
    t.string "attachable_type"
    t.bigint "attachable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "file_name"
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable"
  end

  create_table "client_enrollment_payments", force: :cascade do |t|
    t.string "insurance_id", null: false
    t.string "group"
    t.string "group_employer"
    t.string "provider_phone"
    t.string "subscriber_name"
    t.date "subscriber_dob"
    t.string "subscriber_phone"
    t.integer "relationship"
    t.integer "source_of_payment", default: 0
    t.bigint "funding_source_id"
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_client_enrollment_payments_on_client_id"
    t.index ["funding_source_id"], name: "index_client_enrollment_payments_on_funding_source_id"
  end

  create_table "client_enrollments", force: :cascade do |t|
    t.date "enrollment_date"
    t.date "terminated_on"
    t.string "insureds_name"
    t.text "notes"
    t.bigint "client_id", null: false
    t.bigint "funding_source_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_primary", default: false
    t.index ["client_id"], name: "index_client_enrollments_on_client_id"
    t.index ["funding_source_id"], name: "index_client_enrollments_on_funding_source_id"
  end

  create_table "client_notes", force: :cascade do |t|
    t.bigint "client_id"
    t.text "note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_client_notes_on_client_id"
  end

  create_table "clinics", force: :cascade do |t|
    t.string "name"
    t.string "aka"
    t.string "web"
    t.string "email"
    t.integer "status", default: 0
    t.bigint "organization_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_clinics_on_organization_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "relation_type", default: 0
    t.integer "relation", default: 0
    t.boolean "legal_guardian", default: false, null: false
    t.boolean "resides_with_client", default: false, null: false
    t.boolean "guarantor", default: false, null: false
    t.boolean "parent_portal_access", default: false, null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_address_same_as_client", default: false
    t.index ["client_id"], name: "index_contacts_on_client_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "credentials", force: :cascade do |t|
    t.integer "credential_type"
    t.string "name"
    t.text "description"
    t.boolean "lifetime", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "funding_sources", force: :cascade do |t|
    t.string "name"
    t.string "plan_name"
    t.integer "payer_type", default: 0
    t.string "email"
    t.string "notes"
    t.bigint "clinic_id", null: false
    t.integer "network_status", default: 0
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clinic_id"], name: "index_funding_sources_on_clinic_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "aka"
    t.string "web"
    t.string "email"
    t.integer "status", default: 0
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
    t.json "permissions", default: []
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.integer "status", default: 0
    t.integer "display_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "staff_credentials", force: :cascade do |t|
    t.bigint "staff_id", null: false
    t.bigint "credential_id", null: false
    t.date "issued_at"
    t.date "expires_at"
    t.string "cert_lic_number"
    t.text "documentation_notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["credential_id"], name: "index_staff_credentials_on_credential_id"
    t.index ["staff_id"], name: "index_staff_credentials_on_staff_id"
  end

  create_table "user_clinics", force: :cascade do |t|
    t.bigint "staff_id", null: false
    t.bigint "clinic_id", null: false
    t.boolean "is_home_clinic", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clinic_id"], name: "index_user_clinics_on_clinic_id"
    t.index ["staff_id"], name: "index_user_clinics_on_staff_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
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
    t.integer "payer_status", default: 0
    t.boolean "disqualified", default: false
    t.integer "dq_reason"
    t.integer "preferred_language", default: 0
    t.date "dob"
    t.string "type"
    t.bigint "supervisor_id"
    t.integer "status", default: 0
    t.date "terminated_on"
    t.boolean "service_provider", default: false
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "client_enrollment_payments", "funding_sources"
  add_foreign_key "client_enrollment_payments", "users", column: "client_id"
  add_foreign_key "client_enrollments", "funding_sources"
  add_foreign_key "client_enrollments", "users", column: "client_id"
  add_foreign_key "client_notes", "users", column: "client_id"
  add_foreign_key "clinics", "organizations"
  add_foreign_key "contacts", "users", column: "client_id"
  add_foreign_key "funding_sources", "clinics"
  add_foreign_key "organizations", "users", column: "admin_id"
  add_foreign_key "rbt_supervisions", "users"
  add_foreign_key "staff_credentials", "credentials"
  add_foreign_key "staff_credentials", "users", column: "staff_id"
  add_foreign_key "user_clinics", "clinics"
  add_foreign_key "user_clinics", "users", column: "staff_id"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "user_services", "services"
  add_foreign_key "user_services", "users"
  add_foreign_key "users", "users", column: "supervisor_id"
end
