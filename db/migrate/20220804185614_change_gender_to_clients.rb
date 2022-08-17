class ChangeGenderToClients < ActiveRecord::Migration[6.1]
    def change
       change_column :clients, :gender, :string, default: 'M'
    end
 end