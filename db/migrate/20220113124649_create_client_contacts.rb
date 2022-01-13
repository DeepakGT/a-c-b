class CreateClientContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :client_contacts do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :client, index: true, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
