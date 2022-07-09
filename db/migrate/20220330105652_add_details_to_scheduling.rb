class AddDetailsToScheduling < ActiveRecord::Migration[6.1]
  def change
    add_column :schedulings, :cross_site_allowed, :boolean, default: false
    add_column :schedulings, :service_address_id, :integer
  end
end
