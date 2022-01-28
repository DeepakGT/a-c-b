class CreateClientEnrollments < ActiveRecord::Migration[6.1]
  def change
    create_table :client_enrollments do |t|
      t.date :enrollment_date
      t.date :terminated_on
      t.string :insureds_name
      t.text :notes
      t.text :top_invoice_note
      t.text :bottom_invoice_note
      t.references :client, null: false, foreign_key: {to_table: :users}
      t.references :funding_source, null: false, foreign_key: true

      t.timestamps
    end
  end
end
