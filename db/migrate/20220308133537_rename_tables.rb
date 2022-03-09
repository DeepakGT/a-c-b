class RenameTables < ActiveRecord::Migration[6.1]
  def change
    rename_table :credentials, :qualifications
    rename_table :staff_credentials, :staff_qualifications
    # rename_column :staff_qualifications, :credential_id, :qualification_id
    drop_table :staff_clinic_services
  end
end
