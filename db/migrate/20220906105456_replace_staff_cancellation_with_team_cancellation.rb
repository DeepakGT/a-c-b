class ReplaceStaffCancellationWithTeamCancellation < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.execute "UPDATE schedulings SET status =  REPLACE(status, 'staff_cancellation', 'team_cancellation'); "
    ActiveRecord::Base.connection.execute "UPDATE schedulings SET status =  REPLACE(status, 'staff_cancellation_due_to_illness', 'team_cancellation_due_to_illness'); "
  end
end
