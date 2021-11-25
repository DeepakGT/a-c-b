class CreateQualificationsFundingSources < ActiveRecord::Migration[6.1]
  def change
    create_table :qualifications_funding_sources do |t|
      t.references :qualification, null: false, foreign_key: true
      t.references :funding_source, null: false, foreign_key: true
      t.integer :funding_source_type
      t.string :data_filed

      t.timestamps
    end
  end
end
