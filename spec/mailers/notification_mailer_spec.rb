require 'rails_helper'

RSpec.describe NotificationMailer, :type => :mailer do
  describe 'user_notification' do
    let!(:user) { create(:user,:with_role, role_name: 'super_admin', first_name: 'Jhon') }
    let! (:params) do
      {
        :message=>"created the appointment 1111",
        :notification_url=>"http://localhost:4000/schedule/view/1111",
        :source=> user.class.name,
        :source_id=> user.id,
        :affected => Scheduling.class.name,
        :affected_id => 1111,
        :recipient => user
      }
    end
    let(:mail) { NotificationMailer.with(params).user_notification }

    it 'renders the headers' do
      expect(mail.subject).to eq("Change in #{params[:affected]}")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(user.first_name)
      expect(mail.body.encoded).to match('created the appointment 1111')
    end
  end
end
