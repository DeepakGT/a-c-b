class UpdateRenderedByInSchedulings < ActiveRecord::Migration[6.1]
  def change
    remove_column :schedulings, :rendered_by, :string
    add_reference :schedulings, :rendered_by, foreign_key: {to_table: :users}, null: true
  end
end
