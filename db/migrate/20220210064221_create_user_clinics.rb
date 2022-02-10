class CreateUserClinics < ActiveRecord::Migration[6.1]
  def change
    create_table :user_clinics do |t|
      t.references :staff, null: false, foreign_key: {to_table: :users}
      t.references :clinic, null: false, foreign_key: true
      t.boolean :is_home_clinic, default: false

      t.timestamps
    end
  end
end
