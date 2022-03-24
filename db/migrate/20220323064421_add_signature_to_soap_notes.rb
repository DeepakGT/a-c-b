class AddSignatureToSoapNotes < ActiveRecord::Migration[6.1]
  def change
    add_column :soap_notes, :rbt_signature, :boolean
    add_column :soap_notes, :rbt_signature_author_name, :string
    add_column :soap_notes, :rbt_signature_date, :date
    add_column :soap_notes, :bcba_signature, :boolean
    add_column :soap_notes, :bcba_signature_author_name, :string
    add_column :soap_notes, :bcba_signature_date, :date
    add_column :soap_notes, :clinical_director_signature, :boolean
    add_column :soap_notes, :clinical_director_signature_author_name, :string
    add_column :soap_notes, :clinical_director_signature_date, :date
    add_column :soap_notes, :caregiver_signature_datetime, :datetime
  end
end
