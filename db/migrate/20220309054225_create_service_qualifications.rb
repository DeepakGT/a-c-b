class CreateServiceQualifications < ActiveRecord::Migration[6.1]
  def change
    create_table :service_qualifications do |t|
      t.references :service, null: false, foreign_key: true
      t.references :qualification, null: false, foreign_key: true

      t.timestamps
    end
  end
end
