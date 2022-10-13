class AddTempGenderStaff < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :gender, :gender_tmp
    add_column :users, :gender, :string
  end
end
