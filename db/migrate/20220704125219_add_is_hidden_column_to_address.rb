class AddIsHiddenColumnToAddress < ActiveRecord::Migration[6.1]
  def change
    add_column :addresses, :is_hidden, :boolean, default: false 
  end
end
