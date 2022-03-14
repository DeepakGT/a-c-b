class ChangeSchedulingReferences < ActiveRecord::Migration[6.1]
  def change
    remove_reference :schedulings, :service, foreign_key: true, index: true
    remove_reference :schedulings, :client, foreign_key: {to_table: :users}, index: true
    add_reference :schedulings, :client_enrollment_service, foreign_key: true, index: true
  end
end
