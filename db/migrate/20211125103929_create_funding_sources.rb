class CreateFundingSources < ActiveRecord::Migration[6.1]
  def change
    create_table :funding_sources do |t|
      t.string :name
      t.string :plan_name
      t.integer :payer_type
      t.string :email
      t.string :notes
      t.references :clinic, null: false, foreign_key: true
      t.integer :network_status, default: 0

      t.timestamps
    end
  end
end
