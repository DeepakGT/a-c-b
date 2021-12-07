class CreateServices < ActiveRecord::Migration[6.1]
  def change
    create_table :services do |t|
      t.string :name
      t.integer :status
      t.integer :default_pay_code
      t.integer :category
      t.integer :display_code
      t.integer :tracking_id

      t.timestamps
    end
  end
end
