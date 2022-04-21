class AddJobTypeToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :job_type, :string, default: 'full_time'
    add_column :users, :catalyst_user_id, :text
    add_column :clients, :catalyst_patient_id, :text
  end
end
