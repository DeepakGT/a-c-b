class StaffMailer < ApplicationMailer
  def schedule_update(schedule)     
    @schedule = schedule           
    bootstrap_mail(
      to: schedule.staff.email,      
      subject: 'Change in appointment',
    )   
  end
end