class CreateQualificationsCredentialsFundingSources < ActiveRecord::Migration[6.1]
  def change
    create_table :qualifications_credentials_funding_sources do |t|
      t.references :qualifications_credential, null: false, foreign_key: true, index: {name: 'qualifications_credential_index_on_qual_cred_fund_sources_table'}
      t.references :funding_source, null: false, foreign_key: true, index: {name: 'funding_source_index_on_qual_cred_fund_sources_table'}
      t.integer :funding_source_type
      t.string :data_filed

      t.timestamps
    end
  end
end
