class AddSnowflakeAppointmendIdToScheduling < ActiveRecord::Migration[6.1]
  def change
    add_column :schedulings, :snowflake_appointment_id, :string
  end
end
