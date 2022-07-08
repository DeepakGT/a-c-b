class RemoveUsedLeftScheduledUnitsFromClientEnrollmentService < ActiveRecord::Migration[6.1]
  def change
    remove_column :client_enrollment_services, :used_units, :float
    remove_column :client_enrollment_services, :used_minutes, :float
    remove_column :client_enrollment_services, :scheduled_units, :float
    remove_column :client_enrollment_services, :scheduled_minutes, :float
    remove_column :client_enrollment_services, :left_units, :float
    remove_column :client_enrollment_services, :left_minutes, :float
  end
end
