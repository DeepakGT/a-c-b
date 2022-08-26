class AddDefaultToAddresses < ActiveRecord::Migration[6.1]
  def up
    add_column :addresses, :is_default, :boolean, default: false
    add_column :addresses, :address_name, :string
    remove_index :addresses, name: :index_on_address
    add_index :addresses, %i[addressable_id addressable_type address_type], unique: true, name: 'index_on_address', where: "(address_type = 0 OR address_type = 1)"
  end

  def down
    remove_column :addresses, :is_default
    remove_column :addresses, :address_name
    remove_index :addresses, name: :index_on_address
    add_index :addresses, %i[addressable_id addressable_type address_type], unique: true, name: 'index_on_address'
  end
end
