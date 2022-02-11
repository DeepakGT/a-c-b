class AddPrimaryOptionToClientEnrollment < ActiveRecord::Migration[6.1]
  def change
    add_column :client_enrollments, :is_primary, :boolean, default: false
  end
end
