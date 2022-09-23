class SoapNotesPdfMailer < ApplicationMailer
  def submission(user_id, pdf, client_id)
    @user = User.find_by(id: user_id)
    @client = Client.find_by(id: client_id)
    attachments['soap_notes.pdf'] = pdf
    mail(to: @user.email, subject: "Soap Notes Detail of #{@client.first_name} #{@client.last_name}")
  end
end
