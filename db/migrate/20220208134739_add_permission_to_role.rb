class AddPermissionToRole < ActiveRecord::Migration[6.1]
  def change
    add_column :roles, :permissions, :json, default: []
  end
end
