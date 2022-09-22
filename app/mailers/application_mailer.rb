class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@abacenter.onmicrosoft.com'
  layout 'bootstrap-mailer'
end
