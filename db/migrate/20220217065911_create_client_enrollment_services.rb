class CreateClientEnrollmentServices < ActiveRecord::Migration[6.1]
  def change
    create_table :client_enrollment_services do |t|
      t.date :start_date
      t.date :end_date
      t.float :units
      t.float :minutes
      t.string :service_number
      t.references :client_enrollment, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end
  end
end
