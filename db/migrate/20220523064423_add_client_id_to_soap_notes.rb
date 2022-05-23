class AddClientIdToSoapNotes < ActiveRecord::Migration[6.1]
  def change
    add_reference :soap_notes, :client, foreign_key: { to_table: :clients }, index: true, null: true
  end
end
