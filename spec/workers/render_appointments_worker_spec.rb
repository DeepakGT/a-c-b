require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe RenderAppointmentsWorker, type: :job do
  let!(:time) { (Time.current + 6.hours).to_datetime }
  let!(:scheduled_job) { RenderAppointmentsWorker.perform_in(time, 'SyncWithCatalyst', true) }
  it "sync client SOAP Notes" do
    ActiveJob::Base.queue_adapter = :test
    expect(RenderAppointmentsWorker.jobs).not_to eq([])
    expect(RenderAppointmentsWorker.jobs.last['jid']).to eq(scheduled_job)
  end
end
