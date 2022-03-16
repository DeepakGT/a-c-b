class AddCreatorToSchedulings < ActiveRecord::Migration[6.1]
  def change
    add_reference :schedulings, :creator, foreign_key: { to_table: :users }
    add_reference :schedulings, :updator, foreign_key: { to_table: :users }
  end
end
