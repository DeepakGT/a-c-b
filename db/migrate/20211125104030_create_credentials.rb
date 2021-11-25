class CreateCredentials < ActiveRecord::Migration[6.1]
  def change
    create_table :credentials do |t|
      t.integer :credential_type
      t.string :name
      t.text :description
      t.boolean :lifetime

      t.timestamps
    end
  end
end
