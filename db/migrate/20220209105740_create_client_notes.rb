class CreateClientNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :client_notes do |t|
      t.references :client, null: true, foreign_key: {to_table: :users}
      t.text :note

      t.timestamps
    end
  end
end
