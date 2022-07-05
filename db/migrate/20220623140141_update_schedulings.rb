class UpdateSchedulings < ActiveRecord::Migration[6.1]
  def change
    change_column_null :schedulings, :client_enrollment_service_id, true
  end
end
