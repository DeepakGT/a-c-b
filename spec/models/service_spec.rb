require 'rails_helper'

RSpec.describe Service, type: :model do
  it { should have_many(:service_qualifications).dependent(:destroy) }
  it { should have_many(:qualifications).through(:service_qualifications) }  
  it { should have_many(:client_enrollment_services).dependent(:destroy) } 
  it { should have_many(:staff_clinic_services).dependent(:destroy) }
  it { should have_many(:staff_clinics).through(:staff_clinic_services) }  

  it { should accept_nested_attributes_for(:service_qualifications) }

  it { should define_enum_for(:status)}

  context "display code must contain alphanumeric characters only." do
    it { should allow_value("Abc342").for(:display_code) }
    it { should_not allow_value("test2$!@#%^&*_").for(:display_code) }
  end

  context "#validate_is_early_code" do
    let!(:organization) { create(:organization, name: 'org1') }
    let!(:clinic) { create(:clinic, name: 'clinic1', organization_id: organization.id) }
    let!(:client) { create(:client, clinic_id: clinic.id, first_name: 'test') }
    let!(:service) { create(:service) }
    let!(:client_enrollment) { create(:client_enrollment, client_id: client.id) }
    let!(:client_enrollment_service) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service.id) }
    let!(:staff) { create(:staff, :with_role, role_name: 'administrator', first_name: 'abcd') }
    it "should validate early code column" do
      service.update(is_early_code: true)
      expect(service.errors[:service]).to include(I18n.t('activerecord.attributes.service.validate_is_early_code'))
    end
  end

  context "#validate_selected_payors" do
    let!(:organization) { create(:organization, name: 'org1') }
    let!(:clinic) { create(:clinic, name: 'clinic1', organization_id: organization.id) }
    let!(:client) { create(:client, clinic_id: clinic.id, first_name: 'test') }
    let!(:service) { build :service, is_early_code: true, selected_payors: "[]" }
    it "should validate selected payors" do
      service.validate
      expect(service.errors[:early_service]).to include(I18n.t('activerecord.attributes.service.validate_selected_payors'))
    end
  end
end
