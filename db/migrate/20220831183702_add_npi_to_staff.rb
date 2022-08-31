class AddNpiToStaff < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :npi, :string unless column_exists? :users, :npi
  end
end
