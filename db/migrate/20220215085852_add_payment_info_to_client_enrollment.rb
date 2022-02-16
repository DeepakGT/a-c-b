class AddPaymentInfoToClientEnrollment < ActiveRecord::Migration[6.1]
  def change
    add_column :client_enrollments, :insurance_id, :string
    add_column :client_enrollments, :group, :string
    add_column :client_enrollments, :group_employer, :string
    add_column :client_enrollments, :provider_phone, :string
    add_column :client_enrollments, :relationship, :integer, null: true
    add_column :client_enrollments, :subscriber_name, :string
    add_column :client_enrollments, :subscriber_phone, :string
    add_column :client_enrollments, :subscriber_dob, :date
    add_column :client_enrollments, :source_of_payment, :integer, default: 0
    remove_column :client_enrollments, :insureds_name, :string
    remove_column :users, :payer_status, :integer
    rename_column :funding_sources, :payer_type, :payor_type
    change_column_null :client_enrollments, :funding_source_id, true
  end
end
