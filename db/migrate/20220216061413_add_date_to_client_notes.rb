class AddDateToClientNotes < ActiveRecord::Migration[6.1]
  def change
    add_column :client_notes, :add_date, :date
  end
end
