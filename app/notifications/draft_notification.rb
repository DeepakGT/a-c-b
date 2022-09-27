class DraftNotification < Noticed::Base
  deliver_by :database
  deliver_by :email, mailer: 'NotificationMailer'
end
