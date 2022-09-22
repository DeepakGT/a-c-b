class AddAllowSoapNotesFromConnectToServices < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :allow_soap_notes_from_connect, :boolean, default: false
  end
end
