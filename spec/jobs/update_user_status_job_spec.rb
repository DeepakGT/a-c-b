require 'rails_helper'

RSpec.describe UpdateUserStatusJob, type: :job do
  describe "#perform_later" do
    it "updates user status" do
      ActiveJob::Base.queue_adapter = :test
      expect {UpdateUserStatusJob.perform_later}.to have_enqueued_job
    end
  end
end
