require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe SecondNotificationDraftAppointmentWorker, type: :worker do
  describe 'testing SecondNotificationDraftAppointmentWorker' do
    it 'SecondNotificationDraftAppointmentWorker jobs are enqueued in the scheduled queue' do
      SecondNotificationDraftAppointmentWorker.perform_async
      expect(SecondNotificationDraftAppointmentWorker.queue).to eq('default')
    end
  end
end