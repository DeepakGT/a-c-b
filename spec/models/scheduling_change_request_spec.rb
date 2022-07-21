require 'rails_helper'

RSpec.describe SchedulingChangeRequest, type: :model do
  describe '#associations' do
    # subject { create(:scheduling_change_request) }
    # it { should belong_to(:scheduling) }
    it { SchedulingChangeRequest.reflect_on_association(:scheduling).macro.should eq(:belongs_to) }
  end
  subject { build :scheduling_change_request }

  describe '#enums' do
    it { should define_enum_for(:approval_status) }
  end

  describe "#validate_status" do
    context "RBTs cannot request change status" do
      let(:scheduling_change_request) {build :scheduling_change_request, status: 'scheduled'}
      it "RBTs cannot request change status" do
        scheduling_change_request.validate
        expect(scheduling_change_request.errors[:status]).to include('RBTs cannot request change status to given value.')
      end
    end
    context "No further change requests" do
      let(:scheduling) {create(:scheduling, status: 'Client_No_Show')}
      let(:scheduling_change_request) {build :scheduling_change_request, status: 'Client_Cancel_Greater_than_24_h', scheduling_id: scheduling.id}
      it "No further change requests" do
        scheduling_change_request.validate
        expect(scheduling_change_request.errors[:status]).to include('No further change requests for given schedule can be created.')
      end
    end
  end

  describe "#validate_change_request" do
    context "validate change requests" do
      let!(:scheduling) { create(:scheduling, status: 'scheduled') }
      let!(:scheduling_change_request1) { create(:scheduling_change_request, scheduling_id: scheduling.id, status: 'Client_Cancel_Greater_than_24_h', approval_status: nil) }
      let(:scheduling_change_request) { build :scheduling_change_request, scheduling_id: scheduling.id }

      it "No further change requests for given schedule" do
        scheduling_change_request.validate
        expect(scheduling_change_request.errors[:approval_status]).to include('No further change requests for given schedule can be created unless old change requests are approved or declined.')
      end
    end
  end

end
