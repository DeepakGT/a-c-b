class AddUnrenderedReasonToScheduling < ActiveRecord::Migration[6.1]
  def change
    add_column :schedulings, :unrendered_reason, :string, array: true, default: []
  end
end
