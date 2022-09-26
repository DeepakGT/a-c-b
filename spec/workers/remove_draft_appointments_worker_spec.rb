require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe RemoveDraftAppointmentsWorker, type: :worker do
  describe 'testing RemoveDraftAppointmentsWorker' do
    it 'RemoveDraftAppointmentsWorker jobs are enqueued in the scheduled queue' do
      RemoveDraftAppointmentsWorker.perform_async
      expect(RemoveDraftAppointmentsWorker.queue).to eq('default')
    end
  end
end