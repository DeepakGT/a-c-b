class CreateOrganizations < ActiveRecord::Migration[6.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :aka
      t.string :web
      t.string :email
      t.integer :status, default: 0

      t.references :admin, index: true, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
