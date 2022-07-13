require 'rails_helper'

RSpec.describe ClientEnrollmentService, type: :model do
  describe "associations" do
    let!(:service) { create(:service, is_service_provider_required: false) }
    subject { create(:client_enrollment_service, service_id: service.id) }
    it { should belong_to(:client_enrollment) } 
    # it { should belong_to(:service) } 
    it { ClientEnrollmentService.reflect_on_association(:service).macro.should  eq(:belongs_to) }

    it { should have_many(:service_providers).class_name('ClientEnrollmentServiceProvider').dependent(:destroy) } 
    it { should have_many(:staff).through(:service_providers) }
    it { should have_many(:schedulings).dependent(:destroy) } 
  end
   
  it { should accept_nested_attributes_for(:service_providers) }

  describe "validate_service_providers" do
    context "when is_service_provider_required is true" do
      let(:service) { create(:service, is_service_provider_required: true) }
      let(:client_enrollment_service) { build :client_enrollment_service, service_id: service.id }
      it "must have service providers" do
        client_enrollment_service.validate
        expect(client_enrollment_service.errors[:service_providers]).to include('must be present.')
      end
    end

    context "when is_service_provider_required is false" do
      let(:staff) { create(:staff, :with_role, role_name: 'bcba') }
      let(:service) { create(:service, is_service_provider_required: false) }
      let(:client_enrollment_service) { build :client_enrollment_service, service_id: service.id, service_providers_attributes: [{ staff_id: staff.id}] }
      it "should not have service providers" do
        client_enrollment_service.validate
        expect(client_enrollment_service.errors[:service_providers]).to include('must be absent.')
      end
    end
  end
end