class AddRenderedAtToScheduling < ActiveRecord::Migration[6.1]
  def change
    add_column :schedulings, :rendered_at, :datetime, null: true
  end
end
