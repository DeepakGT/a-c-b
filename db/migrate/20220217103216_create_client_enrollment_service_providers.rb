class CreateClientEnrollmentServiceProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :client_enrollment_service_providers do |t|
      t.references :client_enrollment_service, null: false, foreign_key: true, index: {name: 'index_on_service_provider'}
      t.references :staff, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
