class ChangeBcbaSignDateInSoapNotes < ActiveRecord::Migration[6.1]
  def up
    change_column :soap_notes, :bcba_signature_date, :datetime
  end

  def down
    change_column :soap_notes, :bcba_signature_date, :date
  end
end
