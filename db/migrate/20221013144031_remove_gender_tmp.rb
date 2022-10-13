class RemoveGenderTmp < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :gender_tmp
  end
end
