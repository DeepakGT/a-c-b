class AddIsSoapNotesAssignedToSchedulings < ActiveRecord::Migration[6.1]
  def change
    add_column :schedulings, :is_soap_notes_assigned, :boolean, default: false
  end
end
