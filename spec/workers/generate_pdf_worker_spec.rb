require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe GeneratePdfWorker, type: :job do
  let!(:time) { (Time.current + 6.hours).to_datetime }
  let!(:scheduled_job) { GeneratePdfWorker.perform_in(time, 'GeneratePdf', true) }
  it "sync client SOAP Notes" do
    ActiveJob::Base.queue_adapter = :test
    expect(GeneratePdfWorker.jobs).not_to eq([])
    expect(GeneratePdfWorker.jobs.last['jid']).to eq(scheduled_job)
  end
end
