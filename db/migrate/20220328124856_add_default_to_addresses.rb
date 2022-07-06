class AddDefaultToAddresses < ActiveRecord::Migration[6.1]
  def up
    add_column :addresses, :is_default, :boolean, default: false
    add_column :addresses, :address_name, :string
    # update_address
    remove_index :addresses, name: :index_on_address
    add_index :addresses, %i[addressable_id addressable_type address_type], unique: true, name: 'index_on_address', where: "(address_type = 0 OR address_type = 1)"
  end

  def down
    remove_column :addresses, :is_default
    remove_column :addresses, :address_name
    remove_index :addresses, name: :index_on_address
    add_index :addresses, %i[addressable_id addressable_type address_type], unique: true, name: 'index_on_address'
  end

  # private

  # def update_address
  #   Client.all.each do |client|
  #     client_service_address = client.addresses.find_by_address_type('service_address')
  #     client_service_address.update(is_default: true) if client_service_address.present?
  #   end
  # end
end
