class ChangeAddDateInSoapNotes < ActiveRecord::Migration[6.1]
  def change
    add_column :soap_notes, :add_time, :datetime
  end
end
