class AddRolesIdsToSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :settings, :roles_ids, :text
  end
end
