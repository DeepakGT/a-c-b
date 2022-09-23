class AddAllowSoapNotesFromConnectToServices < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :allow_soap_notes_from_connect, :boolean, default: false
    ActiveRecord::Base.connection.execute "UPDATE services SET allow_soap_notes_from_connect = true where display_code IN ('96112', '96113');"  
  end
end
