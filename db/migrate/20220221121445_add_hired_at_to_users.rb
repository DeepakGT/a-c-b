class AddHiredAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :hired_at, :date
  end
end
