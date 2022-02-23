class CreateSchedulings < ActiveRecord::Migration[6.1]
  def change
    create_table :schedulings do |t|
      t.date :date
      t.time :start_time
      t.time :end_time
      t.string :status
      t.string :units
      t.string :minutes
      t.references :staff, null: false, foreign_key: {to_table: :users}
      t.references :client_enrollment_service, null: false, foreign_key: true

      t.timestamps
    end
  end
end
