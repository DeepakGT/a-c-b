class AddAppointmentOfficeIdToSchedulings < ActiveRecord::Migration[6.1]
  def change
    add_reference :schedulings, :appointment_office, foreign_key: { to_table: :clinics }, null: true
  end
end
