class RenameStaffServices < ActiveRecord::Migration[6.1]
  def change
    remove_reference :staff_services, :staff, foreign_key: {to_table: :users}
    rename_table :staff_services, :staff_clinic_services
    add_reference :staff_clinic_services, :staff_clinic, foreign_key: { to_table: :staff_clinics }
  end
end
