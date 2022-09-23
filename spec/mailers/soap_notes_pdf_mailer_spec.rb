require "rails_helper"

RSpec.describe SoapNotesPdfMailer, type: :mailer do
  let!(:user) { create(:user, :with_role, role_name: 'administrator', email: 'test_user@email.com') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:client) { create(:client, first_name: 'Test', last_name: 'Client') }
  let!(:pdf) { WickedPdf.new.pdf_from_string('<h1>Hello There!</h1>') }

  describe "#submission" do
    context "when sign in" do
      let!(:mail) {SoapNotesPdfMailer.submission(user.id, pdf, client.id)}
      it "should deliver mail successfully" do
        expect(mail.subject).to eq("Soap Notes Detail of #{client.first_name} #{client.last_name}")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq(["from@example.com"])
        expect(mail.attachments.count).to eq(1)
        expect(mail.attachments.first.filename).to eq('soap_notes.pdf')
      end
    end
  end
end
