class PleaseOfService < ActiveRecord::Migration[6.1]
  def change
    add_column :addresses, :aka, :string
  end
end
