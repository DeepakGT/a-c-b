class AddNonBillableReasonToSchedulings < ActiveRecord::Migration[6.1]
  def change
    add_column :schedulings, :non_billable_reason, :text, null: true
  end
end
