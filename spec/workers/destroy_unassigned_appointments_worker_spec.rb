require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe DestroyUnassignedAppointmentsWorker, type: :job do
  let(:time) { (Time.current + 6.hours).to_datetime }
  let(:scheduled_job) { described_class.perform_in(time, 'DestroyUnassignedAppointments', true) }
  describe 'testing worker' do
    it "DestroyUnassignedAppointmentsWorker is enqueued in DestroyUnassignedAppointments queue" do 
      described_class.perform_async
      assert_equal "DestroyUnassignedAppointments", described_class.queue
    end

    it 'goes into the jobs array for testing environment' do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).by(1)
      described_class.new.perform
    end

    context "occurs daily" do
      it 'occurs at expected time' do 
        scheduled_job
        assert_equal true, described_class.jobs.last['jid'].include?(scheduled_job)
        expect(described_class).to have_enqueued_sidekiq_job('DestroyUnassignedAppointments', true)
      end
    end
  end

  # let!(:time) { (Time.current + 6.hours).to_datetime }
  # let!(:scheduled_job) { DestroyUnassignedAppointmentsWorker.perform_in(time, 'SyncWithCatalyst', true) }
  # it "sync client SOAP Notes" do
  #   ActiveJob::Base.queue_adapter = :test
  #   expect(DestroyUnassignedAppointmentsWorker.jobs).not_to eq([])
  #   expect(DestroyUnassignedAppointmentsWorker.jobs.last['jid']).to eq(scheduled_job)
  # end
end
