class AddDeactiveAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :deactivated_at, :datetime
  end
end
