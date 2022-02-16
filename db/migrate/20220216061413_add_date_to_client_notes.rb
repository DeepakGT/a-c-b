class AddDateToClientNotes < ActiveRecord::Migration[6.1]
  def change
    add_column :client_notes, :add_date, :date
    add_reference :client_notes, :creator, foreign_key: { to_table: :users }
  end
end
