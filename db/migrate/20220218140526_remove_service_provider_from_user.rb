class RemoveServiceProviderFromUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :service_provider
  end
end
