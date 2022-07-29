class AddLegacyNumberToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :legacy_number, :string
  end
end
