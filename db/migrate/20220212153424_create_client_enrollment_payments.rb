class CreateClientEnrollmentPayments < ActiveRecord::Migration[6.1]
  def change
    create_table :client_enrollment_payments do |t|
      t.string :insurance_id, null: false
      t.string :group
      t.string :group_employer
      t.string :provider_phone
      t.string :subscriber_name
      t.date :subscriber_dob
      t.string :subscriber_phone
      t.integer :relationship, null: true
      t.integer :source_of_payment, default: 0
      t.references :funding_source, null: true, foreign_key: true
      t.references :client, null: false, foreign_key: {to_table: :users}
      
      t.timestamps
    end
  end
end
