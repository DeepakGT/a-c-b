class AddTrackingIdToClients < ActiveRecord::Migration[6.1]
  def change
    add_column :clients, :tracking_id, :string
  end
end
