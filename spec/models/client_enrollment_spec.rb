require 'rails_helper'

RSpec.describe ClientEnrollment, type: :model do
  describe "#associations" do
    subject {build :client_enrollment}
    it { ClientEnrollment.reflect_on_association(:client).macro.should eq(:belongs_to) }
    it { ClientEnrollment.reflect_on_association(:funding_source).macro.should eq(:belongs_to) }
    it { should have_many(:client_enrollment_services).dependent(:destroy) } 
  end

  describe "#callbacks" do
    it { is_expected.to callback(:set_status).before(:save) }
    it { is_expected.not_to callback(:set_funding_source).before(:validation).on(:create) }
    it { is_expected.to callback(:set_funding_source).before(:validation).on(:update) }
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

    describe "#validate_source_of_payment" do
      context "when client_enrollment is self" do
        let!(:client) { create(:client) }
        let!(:client_enrollment1) { create(:client_enrollment, client_id: client.id, source_of_payment: 'self_pay', funding_source_id: nil) }
        let(:client_enrollment) { build :client_enrollment, client_id: client.id }
        it "cannot have any more client_enrollments" do
          client_enrollment.validate
          expect(client_enrollment.errors[:client]).to include('cannot have more source of payments as self is already present.')
        end
      end

      context "when client_enrollment is insurance" do
        let!(:client) { create(:client) }
        let!(:client_enrollment1) { create(:client_enrollment, client_id: client.id) }
        let(:client_enrollment) { build :client_enrollment, client_id: client.id, source_of_payment: 'self_pay', funding_source_id: nil }
        it "cannot have self pay client_enrollments" do
          client_enrollment.validate
          expect(client_enrollment.errors[:client]).to include('cannot have self source of payment since insurance are already present.')
        end
      end
    end
  end
end
