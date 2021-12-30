class CreateClinics < ActiveRecord::Migration[6.1]
  def change
    create_table :clinics do |t|
      t.string :name
      t.string :aka
      t.string :web
      t.string :email
      t.integer :status, default: 0
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
