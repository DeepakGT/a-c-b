class CreateAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses do |t|
      t.string :line1
      t.string :line2
      t.string :line3
      t.string :zipcode
      t.string :city
      t.string :state
      t.string :country
      t.integer :address_type, default: 0
      t.references :addressable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :addresses, [:addressable_id, :addressable_type, :address_type], unique: true, name: 'index_on_address'
  end
end
