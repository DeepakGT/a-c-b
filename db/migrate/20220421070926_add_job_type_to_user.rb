class AddJobTypeToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :job_type, :string, default: 'full_time'
  end
end
