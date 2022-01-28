class CreateContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :relation_type, default: 0
      t.integer :relation, default: 0
      t.boolean :legal_guardian, default: false, null: false
      t.boolean :resides_with_client, default: false, null: false
      t.boolean :guarantor, default: false, null: false
      t.boolean :parent_portal_access, default: false, null: false
      t.references :client, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
