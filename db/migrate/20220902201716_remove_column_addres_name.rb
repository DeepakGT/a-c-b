class RemoveColumnAddresName < ActiveRecord::Migration[6.1]
  def change
    remove_column :addresses, :address_name
  end
end
