class RemoveNullTrueFromScheduling < ActiveRecord::Migration[6.1]
  def up
    change_column :schedulings, :staff_id, :bigint, null: true
  end

  def down
    change_column :schedulings, :staff_id, :bigint, null: false
  end
end
