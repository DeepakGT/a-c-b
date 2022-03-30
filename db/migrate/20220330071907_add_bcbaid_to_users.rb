class AddBcbaidToUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :bcba, foreign_key: { to_table: :users }, null: true
  end
end
