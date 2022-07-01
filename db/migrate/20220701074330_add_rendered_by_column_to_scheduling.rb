class AddRenderedByColumnToScheduling < ActiveRecord::Migration[6.1]
  def change
    add_column :schedulings, :rendered_by, :string
  end
end
