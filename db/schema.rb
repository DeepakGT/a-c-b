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

ActiveRecord::Schema.define(version: 2022_06_02_094157) do

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
    t.boolean "is_default", default: false
    t.string "address_name"
    t.index ["addressable_id", "addressable_type", "address_type"], name: "index_on_address", unique: true, where: "((address_type = 0) OR (address_type = 1))"
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

  create_table "catalyst_data", force: :cascade do |t|
    t.string "catalyst_soap_note_id"
    t.date "date"
    t.string "start_time"
    t.string "end_time"
    t.text "note"
    t.text "bcba_signature"
    t.text "clinical_director_signature"
    t.json "response"
    t.bigint "system_scheduling_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "caregiver_signature"
    t.text "provider_signature"
    t.float "units"
    t.float "minutes"
    t.boolean "is_appointment_found"
    t.string "multiple_schedulings_ids", default: [], array: true
    t.datetime "date_revision_made"
    t.string "catalyst_patient_id"
    t.string "catalyst_user_id"
    t.index ["is_appointment_found"], name: "index_catalyst_data_on_is_appointment_found"
    t.index ["multiple_schedulings_ids"], name: "index_catalyst_data_on_multiple_schedulings_ids"
    t.index ["system_scheduling_id"], name: "index_catalyst_data_on_system_scheduling_id"
  end

  create_table "client_enrollment_service_providers", force: :cascade do |t|
    t.bigint "client_enrollment_service_id", null: false
    t.bigint "staff_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_enrollment_service_id"], name: "index_on_service_provider"
    t.index ["staff_id"], name: "index_client_enrollment_service_providers_on_staff_id"
  end

  create_table "client_enrollment_services", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.float "units"
    t.float "minutes"
    t.string "service_number"
    t.bigint "client_enrollment_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "left_units", default: 0.0
    t.float "used_units", default: 0.0
    t.float "scheduled_units", default: 0.0
    t.float "left_minutes", default: 0.0
    t.float "used_minutes", default: 0.0
    t.float "scheduled_minutes", default: 0.0
    t.index ["client_enrollment_id"], name: "index_client_enrollment_services_on_client_enrollment_id"
    t.index ["service_id"], name: "index_client_enrollment_services_on_service_id"
  end

  create_table "client_enrollments", force: :cascade do |t|
    t.date "enrollment_date"
    t.date "terminated_on"
    t.text "notes"
    t.bigint "funding_source_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_primary", default: false
    t.string "insurance_id"
    t.string "group"
    t.string "group_employer"
    t.string "provider_phone"
    t.integer "relationship"
    t.string "subscriber_name"
    t.string "subscriber_phone"
    t.date "subscriber_dob"
    t.integer "source_of_payment", default: 0
    t.bigint "client_id"
    t.index ["client_id"], name: "index_client_enrollments_on_client_id"
    t.index ["funding_source_id"], name: "index_client_enrollments_on_funding_source_id"
  end

  create_table "client_notes", force: :cascade do |t|
    t.text "note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "add_date"
    t.bigint "creator_id"
    t.bigint "client_id"
    t.index ["client_id"], name: "index_client_notes_on_client_id"
    t.index ["creator_id"], name: "index_client_notes_on_creator_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "gender", default: 0
    t.boolean "disqualified", default: false
    t.integer "dq_reason"
    t.integer "preferred_language", default: 0
    t.date "dob"
    t.integer "status", default: 0
    t.string "payor_status"
    t.bigint "clinic_id", null: false
    t.bigint "bcba_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "catalyst_patient_id"
    t.string "tracking_id"
    t.index ["bcba_id"], name: "index_clients_on_bcba_id"
    t.index ["clinic_id"], name: "index_clients_on_clinic_id"
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
    t.text "catalyst_clinic_id"
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_address_same_as_client", default: false
    t.bigint "client_id"
    t.index ["client_id"], name: "index_contacts_on_client_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "code"
  end

  create_table "funding_sources", force: :cascade do |t|
    t.string "name"
    t.string "plan_name"
    t.integer "payor_type", default: 0
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

  create_table "qualifications", force: :cascade do |t|
    t.integer "credential_type"
    t.string "name"
    t.text "description"
    t.boolean "lifetime", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  create_table "scheduling_change_requests", force: :cascade do |t|
    t.bigint "scheduling_id", null: false
    t.date "date"
    t.string "start_time"
    t.string "end_time"
    t.string "status"
    t.integer "approval_status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["approval_status"], name: "index_scheduling_change_requests_on_approval_status"
    t.index ["scheduling_id"], name: "index_scheduling_change_requests_on_scheduling_id"
  end

  create_table "schedulings", force: :cascade do |t|
    t.date "date"
    t.string "start_time"
    t.string "end_time"
    t.string "status", default: "Scheduled"
    t.float "units"
    t.float "minutes"
    t.bigint "staff_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "client_enrollment_service_id"
    t.bigint "creator_id"
    t.bigint "updator_id"
    t.boolean "is_rendered", default: false
    t.boolean "cross_site_allowed", default: false
    t.integer "service_address_id"
    t.string "unrendered_reason"
    t.string "catalyst_data_ids", default: [], array: true
    t.datetime "rendered_at"
    t.string "snowflake_appointment_id"
    t.boolean "is_manual_render", default: false
    t.index ["client_enrollment_service_id"], name: "index_schedulings_on_client_enrollment_service_id"
    t.index ["creator_id"], name: "index_schedulings_on_creator_id"
    t.index ["date"], name: "index_schedulings_on_date"
    t.index ["is_rendered"], name: "index_schedulings_on_is_rendered"
    t.index ["staff_id"], name: "index_schedulings_on_staff_id"
    t.index ["start_time"], name: "index_schedulings_on_start_time"
    t.index ["updator_id"], name: "index_schedulings_on_updator_id"
  end

  create_table "service_qualifications", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.bigint "qualification_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["qualification_id"], name: "index_service_qualifications_on_qualification_id"
    t.index ["service_id"], name: "index_service_qualifications_on_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.integer "status", default: 0
    t.string "display_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_service_provider_required", default: false
    t.boolean "is_unassigned_appointment_allowed", default: false
  end

  create_table "settings", force: :cascade do |t|
    t.text "welcome_note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "soap_notes", force: :cascade do |t|
    t.string "note"
    t.date "add_date"
    t.bigint "scheduling_id"
    t.bigint "creator_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "rbt_signature"
    t.string "rbt_signature_author_name"
    t.date "rbt_signature_date"
    t.boolean "bcba_signature"
    t.string "bcba_signature_author_name"
    t.datetime "bcba_signature_date"
    t.boolean "clinical_director_signature"
    t.string "clinical_director_signature_author_name"
    t.date "clinical_director_signature_date"
    t.datetime "caregiver_signature_datetime"
    t.boolean "caregiver_signature", default: false
    t.boolean "synced_with_catalyst", default: false
    t.string "catalyst_data_id"
    t.bigint "client_id"
    t.index ["client_id"], name: "index_soap_notes_on_client_id"
    t.index ["creator_id"], name: "index_soap_notes_on_creator_id"
    t.index ["scheduling_id"], name: "index_soap_notes_on_scheduling_id"
  end

  create_table "staff_clinic_services", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "staff_clinic_id"
    t.index ["service_id"], name: "index_staff_clinic_services_on_service_id"
    t.index ["staff_clinic_id"], name: "index_staff_clinic_services_on_staff_clinic_id"
  end

  create_table "staff_clinics", force: :cascade do |t|
    t.bigint "staff_id", null: false
    t.bigint "clinic_id", null: false
    t.boolean "is_home_clinic", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["clinic_id"], name: "index_staff_clinics_on_clinic_id"
    t.index ["staff_id"], name: "index_staff_clinics_on_staff_id"
  end

  create_table "staff_qualifications", force: :cascade do |t|
    t.bigint "staff_id", null: false
    t.bigint "credential_id", null: false
    t.date "issued_at"
    t.date "expires_at"
    t.string "cert_lic_number"
    t.text "documentation_notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["credential_id"], name: "index_staff_qualifications_on_credential_id"
    t.index ["staff_id"], name: "index_staff_qualifications_on_staff_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
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
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "gender", default: 0
    t.date "dob"
    t.string "type"
    t.bigint "supervisor_id"
    t.integer "status", default: 0
    t.date "terminated_on"
    t.json "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "hired_at"
    t.string "job_type", default: "full_time"
    t.text "catalyst_user_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["supervisor_id"], name: "index_users_on_supervisor_id"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "catalyst_data", "schedulings", column: "system_scheduling_id"
  add_foreign_key "client_enrollment_service_providers", "client_enrollment_services"
  add_foreign_key "client_enrollment_service_providers", "users", column: "staff_id"
  add_foreign_key "client_enrollment_services", "client_enrollments"
  add_foreign_key "client_enrollment_services", "services"
  add_foreign_key "client_enrollments", "funding_sources"
  add_foreign_key "client_notes", "users", column: "creator_id"
  add_foreign_key "clients", "users", column: "bcba_id"
  add_foreign_key "clinics", "organizations"
  add_foreign_key "funding_sources", "clinics"
  add_foreign_key "organizations", "users", column: "admin_id"
  add_foreign_key "rbt_supervisions", "users"
  add_foreign_key "scheduling_change_requests", "schedulings"
  add_foreign_key "schedulings", "client_enrollment_services"
  add_foreign_key "schedulings", "users", column: "creator_id"
  add_foreign_key "schedulings", "users", column: "staff_id"
  add_foreign_key "schedulings", "users", column: "updator_id"
  add_foreign_key "service_qualifications", "qualifications"
  add_foreign_key "service_qualifications", "services"
  add_foreign_key "soap_notes", "clients"
  add_foreign_key "soap_notes", "schedulings"
  add_foreign_key "soap_notes", "users", column: "creator_id"
  add_foreign_key "staff_clinic_services", "services"
  add_foreign_key "staff_clinic_services", "staff_clinics"
  add_foreign_key "staff_clinics", "clinics"
  add_foreign_key "staff_clinics", "users", column: "staff_id"
  add_foreign_key "staff_qualifications", "qualifications", column: "credential_id"
  add_foreign_key "staff_qualifications", "users", column: "staff_id"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "users", column: "supervisor_id"
end
