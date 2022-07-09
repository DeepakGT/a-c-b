class AddUnitsColumnInClientEnrollmentService < ActiveRecord::Migration[6.1]
  def change
    add_column :client_enrollment_services, :left_units, :float, default: 0
    add_column :client_enrollment_services, :used_units, :float, default: 0
    add_column :client_enrollment_services, :scheduled_units, :float, default: 0
    add_column :client_enrollment_services, :left_minutes, :float, default: 0
    add_column :client_enrollment_services, :used_minutes, :float, default: 0
    add_column :client_enrollment_services, :scheduled_minutes, :float, default: 0
  end
end
