require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe SyncStaffAndClientWithCatalystWorker, type: :job do
  let!(:time) { (Time.current + 6.hours).to_datetime }
  let!(:scheduled_job) { SyncStaffAndClientWithCatalystWorker.perform_in(time, 'SyncWithCatalyst', true) }
  it "sync client SOAP Notes" do
    ActiveJob::Base.queue_adapter = :test
    expect(SyncStaffAndClientWithCatalystWorker.jobs).not_to eq([])
    expect(SyncStaffAndClientWithCatalystWorker.jobs.last['jid']).to eq(scheduled_job)
  end
end
