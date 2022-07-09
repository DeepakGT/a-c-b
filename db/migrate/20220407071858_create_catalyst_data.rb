class CreateCatalystData < ActiveRecord::Migration[6.1]
  def change
    create_table :catalyst_data do |t|
      t.string :catalyst_soap_note_id
      t.string :client_first_name
      t.string :client_last_name
      t.string :staff_first_name
      t.string :staff_last_name
      t.date :date
      t.string :start_time
      t.string :end_time
      t.text :note
      t.text :bcba_signature
      t.text :clinical_director_signature
      t.json :response
      t.references :system_scheduling, null: true, foreign_key: { to_table: :schedulings}

      t.timestamps
    end
  end
end
