class AddColumns < ActiveRecord::Migration[6.1]
  def up
    add_column :countries, :code, :string

    add_column :catalyst_data, :date_revision_made, :datetime
    add_column :soap_notes, :catalyst_data_id, :string
    remove_column :catalyst_data, :client_first_name, :string
    remove_column :catalyst_data, :client_last_name, :string
    remove_column :catalyst_data, :staff_first_name, :string
    remove_column :catalyst_data, :staff_last_name, :string
    add_column :catalyst_data, :catalyst_patient_id, :string
    add_column :catalyst_data, :catalyst_user_id, :string

    update_catalyst_data
  end

  def down
    remove_column :countries, :code, :string
    remove_column :catalyst_data, :date_revision_made, :datetime
    remove_column :soap_notes, :catalyst_data_id, :string
    add_column :catalyst_data, :client_first_name, :string
    add_column :catalyst_data, :client_last_name, :string
    add_column :catalyst_data, :staff_first_name, :string
    add_column :catalyst_data, :staff_last_name, :string
    remove_column :catalyst_data, :catalyst_patient_id, :string
    remove_column :catalyst_data, :catalyst_user_id, :string
  end

  private

  def update_catalyst_data
    CatalystData.all.each do |catalyst_data|
      catalyst_data.date_revision_made = catalyst_data&.date&.to_datetime
      catalyst_data.catalyst_patient_id = catalyst_data.response['patientId'] if catalyst_data.response.present?
      catalyst_data.catalyst_user_id = catalyst_data.response['userId'] if catalyst_data.response.present?
      catalyst_data.save(validate: false)
    end
  end
end
