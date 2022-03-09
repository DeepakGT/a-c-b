class UpdateUserStatusJob < ApplicationJob
  queue_as :default

  def perform
    puts "#{DateTime.now}"
    puts "UpdateUserStatusJob is started"
    update_staff_status
    update_client_status
    puts "UpdateUserStatusJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  end

  private

  def update_staff_status
    staff = Staff.all
    staff.each do |staff|
      if staff.terminated_on.present? && staff.terminated_on <= Time.now.to_date
        staff.status = Staff.statuses['inactive']
        staff.save(validate: false)
      end
    end
  end

  def update_client_status
    clients = Client.all
    clients.each do |client|
      client_enrollments = client.client_enrollments
      count = 0
      client_enrollments.each do |client_enrollment|
        if client_enrollment.terminated_on.blank? || staff.terminated_on > Time.now.to_date
          count = 1
          break 
        end
      end
      if count==0
        client.status = Client.statuses['inactive']
        client.save(validate: false)
      end
    end
  end
  # end of private
end
