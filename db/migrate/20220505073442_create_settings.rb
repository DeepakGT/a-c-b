class CreateSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :settings do |t|
      t.text :welcome_note

      t.timestamps
    end
  end
end
