class RenameTables < ActiveRecord::Migration[6.1]
  def change
    rename_table :credentials, :qualifications
    rename_table :staff_credentials, :staff_qualifications
  end
end
