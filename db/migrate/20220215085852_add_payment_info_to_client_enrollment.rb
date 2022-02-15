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
    remove_column :client_enrollments, :notes, :string
    remove_column :client_enrollments, :enrollment_date, :date
    remove_column :client_enrollments, :terminated_on, :date
    rename_column :users, :payer_status, :payor_status
    rename_column :funding_sources, :payer_type, :payor_type
  end
end
