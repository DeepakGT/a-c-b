class ChangeGenderDefault < ActiveRecord::Migration[6.1]
    def change  
      change_column :clients, :gender, :string, default: 'male'  
   end  
end