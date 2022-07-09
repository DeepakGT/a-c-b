class AddIsAppointmentFoundToCatalystData < ActiveRecord::Migration[6.1]
  def change
    add_column :catalyst_data, :is_appointment_found, :boolean
    add_column :catalyst_data, :multiple_schedulings_ids, :string, array: true, default:[]
  end
end
