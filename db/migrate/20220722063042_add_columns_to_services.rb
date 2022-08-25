class AddColumnsToServices < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :selected_non_early_services, :string
    add_column :services, :selected_non_billable_payors, :string
    add_column :services, :payors_requiring_rendering_provider, :string
  end
end
