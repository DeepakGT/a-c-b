require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe FirstNotificationDraftAppointmentWorker, type: :worker do
  describe 'testing FirstNotificationDraftAppointmentWorker' do
    it 'FirstNotificationDraftAppointmentWorker jobs are enqueued in the scheduled queue' do
      FirstNotificationDraftAppointmentWorker.perform_async
      expect(FirstNotificationDraftAppointmentWorker.queue).to eq('default')
    end
  end
end
