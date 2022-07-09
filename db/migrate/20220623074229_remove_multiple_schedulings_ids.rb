class RemoveMultipleSchedulingsIds < ActiveRecord::Migration[6.1]
  def change
    remove_column :catalyst_data, :multiple_schedulings_ids, :string, default: [], array: true
  end
end
