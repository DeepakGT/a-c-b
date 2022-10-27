class RemovePayorStatusColumnFromClients < ActiveRecord::Migration[6.1]
  def change
    remove_column :clients, :payor_status, :string if column_exists? :clients, :payor_status
  end
end
