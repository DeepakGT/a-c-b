class AddJobTypeToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :job_type, :string, default: 'full_time'
    add_column :users, :catalyst_user_id, :text
    add_column :clients, :catalyst_patient_id, :text
    add_column :clinics, :catalyst_clinic_id, :text

    remove_reference :users, :clinic, null: true
    remove_column :users, :disqualified, :boolean
    remove_column :users, :dq_reason, :integer
    remove_column :users, :preferred_language, :integer
    remove_column :users, :payor_status, :string
    remove_reference :users, :bcba, foreign_key: { to_table: :users }, null: true
  end
end
