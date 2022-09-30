class CreateServiceAddressTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :service_address_types do |t|
      t.string :name
      t.integer :tag_num
      t.timestamps
    end

    add_reference :addresses, :service_address_type, foreign_key: true
    change_column_null :addresses, :service_address_type_id, true
  end
end
