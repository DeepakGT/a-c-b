class CreateClinics < ActiveRecord::Migration[6.1]
  def change
    create_table :clinics do |t|
      t.string :name
      t.text :address
      t.string :city
      t.string :state
      t.string :zipcode
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
