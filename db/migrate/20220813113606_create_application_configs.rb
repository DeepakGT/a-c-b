class CreateApplicationConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :application_configs do |t|
      t.string :config_key
      t.text :config_value

      t.timestamps
    end unless table_exists? "application_configs"
  end
end
