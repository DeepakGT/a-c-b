require 'rails_helper' 
require 'sidekiq/testing'

RSpec.describe SyncWithCatalystWorker, type: :job do
  let!(:time) { (Time.current + 6.hours).to_datetime }
  let!(:scheduled_job) { SyncWithCatalystWorker.perform_in(time, 'SyncWithCatalyst', true) }
  it "sync client SOAP Notes" do
    ActiveJob::Base.queue_adapter = :test
    expect(SyncWithCatalystWorker.jobs).not_to eq([])
    expect(SyncWithCatalystWorker.jobs.last['jid']).to eq(scheduled_job)
  end
end
