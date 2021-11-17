class CreateAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses do |t|
      t.string :line_1
      t.string :line_2
      t.string :line_3
      t.string :zipcode
      t.string :city
      t.string :state
      t.string :country
      t.references :addressable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
