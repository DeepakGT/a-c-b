class CreateQualifications < ActiveRecord::Migration[6.1]
  def change
    create_table :qualifications do |t|
      t.references :staff, null: false, index: true, foreign_key: {to_table: :users}
      t.date :tb_cleared_at
      t.date :doj_cleared_at
      t.date :fbi_cleared_at
      t.date :tb_expires_at
      t.date :doj_expires_at
      t.date :fbi_expires_at

      t.timestamps
    end
  end
end
