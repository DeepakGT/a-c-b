class CreateQualificationsCredentials < ActiveRecord::Migration[6.1]
  def change
    create_table :qualifications_credentials do |t|
      t.references :qualification, null: false, foreign_key: true
      t.references :credential, null: false, foreign_key: true
      t.date :issued_at
      t.date :expires_at
      t.string :cert_lic_number
      t.text :documentation_notes

      t.timestamps
    end
  end
end
