class ChangeScheduling < ActiveRecord::Migration[6.1]
  def change
    change_column :schedulings, :units, :float, using: "units::double precision"
    change_column :schedulings, :minutes, :float, using: "minutes::double precision"
  end
end
