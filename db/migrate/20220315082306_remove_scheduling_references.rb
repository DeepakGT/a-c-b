class RemoveSchedulingReferences < ActiveRecord::Migration[6.1]
  def change
    remove_reference :schedulings, :service, foreign_key: true, index: true
    remove_reference :schedulings, :client, foreign_key: {to_table: :users}, index: true
  end
end
