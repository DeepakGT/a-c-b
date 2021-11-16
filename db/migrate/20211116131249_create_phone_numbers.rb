class CreatePhoneNumbers < ActiveRecord::Migration[6.1]
  def change
    create_table :phone_numbers do |t|
      t.integer :phone_type
      t.string :number
      t.references :phoneable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
