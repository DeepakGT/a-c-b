class CreateNewClients < ActiveRecord::Migration[6.1]
  def up
    create_table :new_clients do |t|
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
      t.references :clinic, null: false
      t.references :bcba, foreign_key: {to_table: :users}, null: true

      t.timestamps
    end

    Rake::Task['update_new_client:copy_client_data'].invoke

    add_reference :client_enrollments, :new_client, index: true
    add_reference :contacts, :new_client, index: true
    add_reference :client_notes, :new_client, index: true

    Rake::Task['update_new_client:update_new_client_ids'].invoke

    remove_reference :contacts, :client, foreign_key: {to_table: :users}
    remove_reference :client_enrollments, :client, foreign_key: {to_table: :users}
    remove_reference :client_notes, :client, foreign_key: {to_table: :users}, null: true
  end

  def down 
    drop_table :new_clients do |t|
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
      t.integer "client_id"
      t.references :clinic, null: false
      t.references :bcba, foreign_key: {to_table: :users}, null: true

      t.timestamps
    end

    add_reference :contacts, :client, foreign_key: {to_table: :users}
    add_reference :client_enrollments, :client, foreign_key: {to_table: :users}
    add_reference :client_notes, :client, foreign_key: {to_table: :users}

    Rake::Task['update_new_client:update_client_ids'].invoke

    remove_reference :client_enrollments, :new_client, index: true
    remove_reference :contacts, :new_client, index: true
    remove_reference :client_notes, :new_client, index: true
  end
end
