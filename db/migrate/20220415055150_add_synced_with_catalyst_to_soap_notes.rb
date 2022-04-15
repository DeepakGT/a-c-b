class AddSyncedWithCatalystToSoapNotes < ActiveRecord::Migration[6.1]
  def change
    add_column :soap_notes, :synced_with_catalyst, :boolean, default: false
  end
end
