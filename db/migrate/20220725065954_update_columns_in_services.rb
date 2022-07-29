class UpdateColumnsInServices < ActiveRecord::Migration[6.1]
  def change
    remove_column :services, :selected_non_billable_payors, :string
    remove_column :services, :payors_requiring_rendering_provider, :string

    add_column :services, :selected_payors, :json, default: []
    add_column :services, :max_units, :float
  end
end
