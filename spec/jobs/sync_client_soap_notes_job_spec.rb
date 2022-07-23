require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe SyncClientSoapNotesJob, type: :job do
  describe "#perform_later" do
    it "sync client SOAP Notes" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        SyncClientSoapNotesJob.perform_later
      }.to have_enqueued_job
    end
  end
end
