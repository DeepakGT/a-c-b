class CreateSchedulingChangeRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :scheduling_change_requests do |t|
      t.references :scheduling, null: false, foreign_key: true
      t.date :date
      t.string :start_time
      t.string :end_time
      t.string :status
      t.integer :approval_status, null: true

      t.timestamps
    end
  end
end
