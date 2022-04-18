class AddUnrenderedReasonToScheduling < ActiveRecord::Migration[6.1]
  def change
    add_column :schedulings, :unrendered_reason, :string
  end
end
