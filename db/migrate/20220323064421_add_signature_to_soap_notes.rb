class AddSignatureToSoapNotes < ActiveRecord::Migration[6.1]
  def change
    add_column :soap_notes, :rbt_sign, :boolean
    add_column :soap_notes, :rbt_sign_name, :string
    add_column :soap_notes, :rbt_sign_date, :date
    add_column :soap_notes, :bcba_sign, :boolean
    add_column :soap_notes, :bcba_sign_name, :string
    add_column :soap_notes, :bcba_sign_date, :date
    add_column :soap_notes, :clinical_director_sign, :boolean
    add_column :soap_notes, :clinical_director_sign_name, :string
    add_column :soap_notes, :clinical_director_sign_date, :date
  end
end
