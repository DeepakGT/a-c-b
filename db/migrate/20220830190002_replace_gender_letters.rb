class ReplaceGenderLetters < ActiveRecord::Migration[6.1]
    def change  
      ActiveRecord::Base.connection.execute "UPDATE clients SET gender =  REPLACE(gender, 'M', 'male'); "  
      ActiveRecord::Base.connection.execute "UPDATE clients SET gender =  REPLACE(gender, 'F', 'female'); "      
    end  
  end