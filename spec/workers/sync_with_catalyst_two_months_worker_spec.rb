require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe SyncWithCatalystTwoMonthsWorker, type: :job do
  let!(:time) { (Time.current + 6.hours).to_datetime }
  let!(:scheduled_job) { SyncWithCatalystTwoMonthsWorker.perform_in(time, 'SyncWithCatalyst', true) }
  it "sync client SOAP Notes" do
    ActiveJob::Base.queue_adapter = :test
    expect(SyncWithCatalystTwoMonthsWorker.jobs).not_to eq([])
    expect(SyncWithCatalystTwoMonthsWorker.jobs.last['jid']).to eq(scheduled_job)
  end
end
