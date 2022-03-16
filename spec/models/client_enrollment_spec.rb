require 'rails_helper'

RSpec.describe ClientEnrollment, type: :model do
  describe "#associations" do
    subject {build :client_enrollment}
    # it { should belong_to(:client) } 
    # it { should belong_to(:funding_source).optional } 
    it { should have_many(:client_enrollment_services).dependent(:destroy) } 
  end
  
  describe "#enums" do
    it { should define_enum_for(:relationship) }
    it { should define_enum_for(:source_of_payment) }  
  end
  
  describe "#validations" do
    subject {build :client_enrollment}
    it { should validate_presence_of(:terminated_on) }

    describe "#validate_funding_source" do
      context "when source of payment is self, funding source" do
        let(:client_enrollment) {build :client_enrollment, source_of_payment: 'self_pay'}
        it "should be absent" do
          client_enrollment.validate
          expect(client_enrollment.errors[:funding_source]).to include('must be absent.')
        end
      end

      context "when source of payment is insurance, funding source" do
        let(:client_enrollment) {build :client_enrollment, funding_source_id: nil}
        it "should be present" do
          client_enrollment.validate
          expect(client_enrollment.errors[:funding_source]).to include('must be present.')
        end
      end
    end
  end
end
