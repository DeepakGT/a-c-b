class AddSignatureToCatalystData < ActiveRecord::Migration[6.1]
  def change
    add_column :catalyst_data, :caregiver_signature, :text
    add_column :catalyst_data, :provider_signature, :text
    add_column :catalyst_data, :units, :float
    add_column :catalyst_data, :minutes, :float
    add_column :soap_notes, :caregiver_signature, :boolean, default: false
    add_column :schedulings, :catalyst_data_ids, :string, array: true, default: []
  end
end
