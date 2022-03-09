class ChangeColumntypeInSchedulings < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        change_column :schedulings, :start_time, :string
        change_column :schedulings, :end_time, :string
      end
      dir.down do
        change_column :schedulings, :start_time, :datetime, using: 'start_time::timestamp without time zone'
        change_column :schedulings, :end_time, :datetime, using: 'start_time::timestamp without time zone'
      end
    end
  end
end
