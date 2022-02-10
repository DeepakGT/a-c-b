class AddHomeClinicToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :is_home_clinic, :boolean, default: false
  end
end
