class ChangeService < ActiveRecord::Migration[6.1]
  def change
    change_column :services, :display_code, :string
  end
end
