class AddLocationAndSessionLocationToCatalystData < ActiveRecord::Migration[6.1]
  def change
    add_column :catalyst_data, :location, :string
    add_column :catalyst_data, :session_location, :string
  end
end
