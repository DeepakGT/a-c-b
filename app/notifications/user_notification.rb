class UserNotification < Noticed::Base
  deliver_by :database
  #deliver_by :email, mailer: "ApplicationMailer", if: :email_notifications?

end
