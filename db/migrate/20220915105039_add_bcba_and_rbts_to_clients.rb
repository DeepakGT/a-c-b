class AddBcbaAndRbtsToClients < ActiveRecord::Migration[6.1]
  def change
    rename_column :clients, :bcba_id, :primary_bcba_id
    add_reference :clients, :secondary_bcba, foreign_key: { to_table: :users }, null: true
    add_reference :clients, :primary_rbt, foreign_key: { to_table: :users }, null: true
    add_reference :clients, :secondary_rbt, foreign_key: { to_table: :users }, null: true
  end
end
