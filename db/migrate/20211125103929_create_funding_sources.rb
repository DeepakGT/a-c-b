class CreateFundingSources < ActiveRecord::Migration[6.1]
  def change
    create_table :funding_sources do |t|
      t.string :name
      t.string :title
      t.references :clinic, null: false, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
