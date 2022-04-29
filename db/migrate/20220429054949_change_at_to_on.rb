class ChangeAtToOn < ActiveRecord::Migration[6.1]
  def change
    rename_column :staff_qualifications, :issued_at, :issued_on
    rename_column :staff_qualifications, :expires_at, :expires_on
    rename_column :users, :hired_at, :hired_on
    rename_column :schedulings, :unrendered_reason, :unrendered_reasons
  end
end
