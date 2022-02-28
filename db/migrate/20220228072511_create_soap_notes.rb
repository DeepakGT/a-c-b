class CreateSoapNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :soap_notes do |t|
      t.string :note
      t.date :add_date
      t.references :scheduling, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
