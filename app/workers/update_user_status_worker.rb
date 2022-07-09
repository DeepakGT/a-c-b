require 'sidekiq'
require 'sidekiq-cron'
class UpdateUserStatusWorker                       
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.current}"
    puts "UpdateUserStatusJob is started"
    update_staff_status
    # update_client_status
    puts "UpdateUserStatusJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"               
  end

  private

  def update_staff_status
    Loggers::UpdateUserStatusLoggerService.call(nil, "Update user status on #{Time.current.to_date} has started.")
    staffs = Staff.all
    staffs.each do |staff|
      if staff.terminated_on.present? && staff.terminated_on <= Time.current.to_date
        staff.status = Staff.statuses['inactive']
        staff.save(validate: false)
        if staff.status=='inactive'
          Loggers::UpdateUserStatusLoggerService.call(staff.id, "Staff #{staff.id} status is updated to inactive.")
        else
          Loggers::UpdateUserStatusLoggerService.call(staff.id, "Staff #{staff.id} status cannot be updated to inactive.")
        end
      end
    end
    Loggers::UpdateUserStatusLoggerService.call(nil, "Update user status on #{Time.current.to_date} is completed.")
  end

  # def update_client_status
  #   clients = Client.all
  #   clients.each do |client|
  #     client_enrollments = client.client_enrollments
  #     count = 0
  #     client_enrollments.each do |client_enrollment|
  #       if client_enrollment.terminated_on.blank? || client_enrollment.terminated_on > Time.current.to_date
  #         count = 1
  #         break 
  #       end
  #     end
  #     if count==0
  #       client.status = Client.statuses['inactive']
  #       client.save(validate: false)
  #     end
  #   end
  # end
  # end of private
end
