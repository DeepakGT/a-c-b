class AddIsAddressSameAsClientToContact < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :is_address_same_as_client, :boolean, default: false
  end
end
