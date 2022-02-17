class RenameUserServices < ActiveRecord::Migration[6.1]
  def change
    remove_reference :user_services, :user, foreign_key: {to_table: :users}
    rename_table :user_services, :staff_services
    add_reference :staff_services, :staff, foreign_key: { to_table: :users }, null: false
  end
end
