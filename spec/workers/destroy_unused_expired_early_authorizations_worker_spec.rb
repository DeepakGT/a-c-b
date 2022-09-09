require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe DestroyUnassignedAppointmentsWorker, type: :job do
  let!(:time) { (Time.current + 6.hours).to_datetime }
  let!(:scheduled_job) { DestroyUnusedExpiredEarlyAuthorizationsWorker.perform_in(time, 'DestroyUnusedExpiredEarlyAuthorizations', true) }
  it "sync client SOAP Notes" do
    ActiveJob::Base.queue_adapter = :test
    expect(DestroyUnusedExpiredEarlyAuthorizationsWorker.jobs).not_to eq([])
    expect(DestroyUnusedExpiredEarlyAuthorizationsWorker.jobs.last['jid']).to eq(scheduled_job)
  end
end
