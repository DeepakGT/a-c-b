class NotificationMailer < ApplicationMailer
  def user_notification
    @user = User.find_by(id: params[:source_id])
    @params = params
    bootstrap_mail(
      to: params[:recipient].email,
      subject: "Change in #{params[:affected]}"
      )
  end

  def draft_notification
    @params = params
    bootstrap_mail(
      to: params[:recipient].email,
      subject: "#{I18n.t('.notification.draft_appointment.subject')} #{params[:affected]}"
    )
  end
end
