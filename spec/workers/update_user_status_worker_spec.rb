require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe UpdateUserStatusWorker, type: :job do
  let!(:time) { (Time.current + 6.hours).to_datetime }
  let!(:scheduled_job) { UpdateUserStatusWorker.perform_in(time, 'SyncWithCatalyst', true) }
  it "sync client SOAP Notes" do
    ActiveJob::Base.queue_adapter = :test
    expect(UpdateUserStatusWorker.jobs).not_to eq([])
    expect(UpdateUserStatusWorker.jobs.last['jid']).to eq(scheduled_job)
  end
end
