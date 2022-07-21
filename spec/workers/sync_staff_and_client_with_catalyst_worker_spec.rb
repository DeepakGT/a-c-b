require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe SyncStaffAndClientWithCatalystWorker, type: :job do
  let(:time) { (Time.current + 6.hours).to_datetime }
  let(:scheduled_job) { described_class.perform_in(time, 'SyncStaffAndClientWithCatalyst', true) }
  describe 'testing worker' do
    it "SyncStaffAndClientWithCatalystWorker is enqueued in SyncStaffAndClientWithCatalyst queue" do 
      described_class.perform_async
      assert_equal "SyncStaffAndClientWithCatalyst", described_class.queue
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
        expect(described_class).to have_enqueued_sidekiq_job('SyncStaffAndClientWithCatalyst', true)
      end
    end
  end

  # let!(:time) { (Time.current + 6.hours).to_datetime }
  # let!(:scheduled_job) { SyncStaffAndClientWithCatalystWorker.perform_in(time, 'SyncWithCatalyst', true) }
  # it "sync client SOAP Notes" do
  #   ActiveJob::Base.queue_adapter = :test
  #   expect(SyncStaffAndClientWithCatalystWorker.jobs).not_to eq([])
  #   expect(SyncStaffAndClientWithCatalystWorker.jobs.last['jid']).to eq(scheduled_job)
  # end
end
