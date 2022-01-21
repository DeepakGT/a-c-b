class CreateContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :relation_type
      t.integer :relation
      t.boolean :legal_guardian, default: false
      t.boolean :resides_with_client, default: false
      t.boolean :guarantor, default: false
      t.boolean :parent_portal_access, default: false
      t.references :client, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
