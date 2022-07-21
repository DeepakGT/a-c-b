class AddDefaultScheduleViewToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :default_schedule_view, :string, default: 'calendar'
  end
end
