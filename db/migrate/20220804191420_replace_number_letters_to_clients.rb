class ReplaceNumberLettersToClients < ActiveRecord::Migration[6.1]
    def change
      ActiveRecord::Base.connection.execute "UPDATE clients SET gender =  REPLACE(gender, '0', 'M'); "
      ActiveRecord::Base.connection.execute "UPDATE clients SET gender =  REPLACE(gender, '1', 'F'); "    
    end
  end