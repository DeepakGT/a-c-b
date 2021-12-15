class CreateServices < ActiveRecord::Migration[6.1]
  def change
    create_table :services do |t|
      t.string :name
      t.integer :status, default: 0
      t.integer :display_code

      t.timestamps
    end
  end
end
