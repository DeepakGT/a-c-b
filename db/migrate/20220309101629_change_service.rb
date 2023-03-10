class ChangeService < ActiveRecord::Migration[6.1]
  def up
    change_column :services, :display_code, :string
    add_column :services, :is_service_provider_required, :boolean, default: false
    change_column_default :schedulings, :status, from: nil, to: 'Scheduled'
  end

  def down 
    change_column :services, :display_code, :integer
    remove_column :services, :is_service_provider_required, :boolean, default: false
    change_column_default :schedulings, :status, from: 'Scheduled', to: nil
  end
end
