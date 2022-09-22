class ChangeStatusDefaultInSchedulings < ActiveRecord::Migration[6.1]
  def change
    change_column_default :schedulings, :status, from: 'Scheduled', to: 'scheduled'
  end
end
