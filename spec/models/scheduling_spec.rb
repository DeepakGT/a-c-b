require 'rails_helper'

RSpec.describe Scheduling, type: :model do
  it { should belong_to(:staff) }
  it { should belong_to(:client) }
  it { should belong_to(:service) }
  it { should have_many(:soap_notes).dependent(:destroy) } 

  describe "#validate_time" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:client) { create(:client, clinic_id: clinic.id) }
    let!(:service) { create(:service) }
    let!(:staff) { create(:staff, :with_role, role_name: 'bcba') }
    let!(:scheduling1) { create(:scheduling, staff_id: staff.id, client_id: client.id, 
      service_id: service.id, start_time: '16:00', end_time: '17:00', date: '2022-02-28')}
    let(:scheduling) { build :scheduling, staff_id: staff.id, client_id: client.id, 
      service_id: service.id, start_time: '16:00', end_time: '17:00', date: '2022-02-28' }
    
    context "when scheduling with same staff,client, service at same time is present" do
      it "should give an error" do
        scheduling.validate
        expect(scheduling.errors[:scheduling]).to include('must not have overlapping time for same staff, client and service on same date')
      end
    end
  end
end
