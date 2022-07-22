class AddEarlyCodeToServices < ActiveRecord::Migration[6.1]
  def change
    add_column :services, :is_early_code, :boolean, default: false
  end
end
