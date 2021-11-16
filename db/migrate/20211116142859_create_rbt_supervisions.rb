class CreateRbtSupervisions < ActiveRecord::Migration[6.1]
  def change
    create_table :rbt_supervisions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
