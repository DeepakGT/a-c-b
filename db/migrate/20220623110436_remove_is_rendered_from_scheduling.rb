class RemoveIsRenderedFromScheduling < ActiveRecord::Migration[6.1]
  def change
    remove_column :schedulings, :is_rendered, :boolean
  end
end
