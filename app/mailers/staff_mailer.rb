class StaffMailer < ApplicationMailer
  def schedule_update(schedule)     
    @schedule = schedule    
    if Rails.env.development?
      @url = "http://localhost:4000/schedule/view/#{schedule.id}"    
    elsif Rails.env.test?
      @url = "https://stage989800.abaconnectemr.com/schedule/view#{schedule.id}"    
    else Rails.env.production?
      @url = "https://abaconnectemr.com/schedule/view/#{schedule.id}"    
    end    
    bootstrap_mail(
      to: schedule.user.email,      
      subject: 'Change in appointment',
    )   
  end
end
