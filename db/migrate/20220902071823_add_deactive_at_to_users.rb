class AddDeactiveAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :deactive_at, :datetime
  end
end
