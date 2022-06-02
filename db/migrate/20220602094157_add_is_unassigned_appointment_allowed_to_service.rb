class AddIsUnassignedAppointmentAllowedToService < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :is_unassigned_appointment_allowed, :boolean, default: false
  end
end
