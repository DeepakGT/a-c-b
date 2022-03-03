require 'rails_helper'

RSpec.describe Scheduling, type: :model do
  describe 'associations' do
    it { should belong_to(:staff) }
    it { should belong_to(:client) }
    it { should belong_to(:service) }
    it { should have_many(:soap_notes).dependent(:destroy) } 
  end

  describe "validations" do
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { should validate_presence_of(:status) }

    context "when both units and minutes are absent" do
      subject { build :scheduling } 
      it { should validate_presence_of(:units).with_message('or minutes, any one must be present.') }
    end

    context "when both units and minutes are present" do
      subject { build :scheduling, units: '6', minutes: '300' }
      it { should validate_absence_of(:units).with_message('or minutes, only one must be present.') }
    end
  end

  describe "#validate_time" do
    let!(:clinic) { create(:clinic, name: 'clinic1') }
    let!(:client) { create(:client, clinic_id: clinic.id) }
    let!(:service) { create(:service) }
    let!(:staff) { create(:staff, :with_role, role_name: 'bcba') }
    let!(:scheduling1) { create(:scheduling, staff_id: staff.id, client_id: client.id, 
      service_id: service.id, start_time: '16:00', end_time: '17:00', date: '2022-02-28', units: '2')}
    let(:scheduling) { build :scheduling, staff_id: staff.id, client_id: client.id, 
      service_id: service.id, start_time: '16:00', end_time: '17:00', date: '2022-02-28', units: '2' }
    
    context "when scheduling with same staff,client, service at same time is present" do
      it "should give an error" do
        scheduling.validate
        expect(scheduling.errors[:scheduling]).to include('must not have overlapping time for same staff, client and service on same date')
      end
    end
  end
end
