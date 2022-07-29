class AddSelectedNonEarlyServiceIdToServices < ActiveRecord::Migration[6.1]
  def change
    remove_column :services, :selected_non_early_services, :string
    add_column :services, :selected_non_early_service_id, :bigint
  end
end
