class RenameNewClientToClient < ActiveRecord::Migration[6.1]
  def up
    rename_table :new_clients, :clients
    rename_column :contacts, :new_client_id, :client_id
    rename_column :client_enrollments, :new_client_id, :client_id
    rename_column :client_notes, :new_client_id, :client_id

    Rake::Task['update_new_client:rename_new_client'].invoke
  end

  def down
    rename_table  :clients, :new_clients
    rename_column :contacts, :client_id, :new_client_id
    rename_column :client_enrollments, :client_id, :new_client_id
    rename_column :client_notes, :client_id, :new_client_id
  end
end
