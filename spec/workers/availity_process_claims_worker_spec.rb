require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe AvailityProcessClaimsWorker, type: :worker do
  let(:time) { (Time.current + 5.minutes).to_datetime }
  let(:scheduled_job) { AvailityProcessClaimsWorker.perform_at(time, 'AvailityProcessClaims', true) }
  describe 'testing AvailityProcessClaimsWorker' do
    it 'AvailityProcessClaimsWorker jobs are enqueued in the scheduled queue' do
      AvailityProcessClaimsWorker.perform_async
      assert_equal :scheduled, AvailityProcessClaimsWorker.queue
    end

    it 'goes into the jobs array for testing environment' do
      expect do
        AvailityProcessClaimsWorker.perform_async
      end.to change(AvailityProcessClaimsWorker.jobs, :size).by(1)
      AvailityProcessClaimsWorker.new.perform
    end

    context 'occurs at expected time' do
      it 'occurs at expected time' do
        scheduled_job
        assert_equal true, AvailityProcessClaimsWorker.jobs.last['jid'].include?(scheduled_job)
        expect(AvailityProcessClaimsWorker).to have_enqueued_sidekiq_job('AvailityProcessClaims', true)
      end
    end
  end
end
