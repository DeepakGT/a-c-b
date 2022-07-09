class RemoveColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :catalyst_data, :is_appointment_found, :boolean
    remove_column :schedulings, :is_rendered, :boolean
  end
end
