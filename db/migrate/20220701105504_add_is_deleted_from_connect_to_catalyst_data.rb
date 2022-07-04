class AddIsDeletedFromConnectToCatalystData < ActiveRecord::Migration[6.1]
  def change
    add_column :catalyst_data, :is_deleted_from_connect, :boolean, default: false
  end
end
