class AddPayorStatusToClientEnrollments < ActiveRecord::Migration[6.1]
  def change
    add_column :client_enrollments, :payor_status, :string unless column_exists? :client_enrollments, :payor_status
  end
end
