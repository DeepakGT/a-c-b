class ChangeSchedulingIdInSoapNotes < ActiveRecord::Migration[6.1]
  def change
    change_column_null :soap_notes, :scheduling_id, true
    change_column_null :soap_notes, :creator_id, true
  end
end
