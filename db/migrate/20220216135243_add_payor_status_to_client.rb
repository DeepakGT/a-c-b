class AddPayorStatusToClient < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :payor_status, :string, null:true
  end
end
