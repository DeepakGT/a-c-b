class AddIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :schedulings, :date
    add_index :schedulings, :is_rendered
    add_index :schedulings, :start_time

    add_index :catalyst_data, :is_appointment_found
    add_index :catalyst_data, :multiple_schedulings_ids
    
    add_index :scheduling_change_requests, :approval_status
  end
end
