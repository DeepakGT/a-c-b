require 'rails_helper'

RSpec.describe FundingSource, type: :model do
  it { should have_one(:phone_number).dependent(:destroy)}
  it { should have_one(:address).dependent(:destroy)}
  it { should have_many(:client_enrollments).dependent(:nullify) }
  it { should have_many(:clients).through(:client_enrollments) }  
  it { should belong_to(:clinic) }

  it { should define_enum_for(:status)}
  it { should define_enum_for(:network_status)}
  it { should define_enum_for(:payor_type)}

  it { should accept_nested_attributes_for(:phone_number).update_only(true)}
  it { should accept_nested_attributes_for(:address).update_only(true)}

  describe "#validate_non_billable_payors" do
    let!(:funding_source){create(:funding_source, network_status: 'in_network')}
    let!(:client_enrollment){create(:client_enrollment, source_of_payment: 'insurance', funding_source_id: funding_source.id)}
    let!(:service){create(:service)}
    let!(:client_enrollment_service){create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service.id)}
    it "should show validation error" do
      funding_source.update(network_status: 'non_billable')
      expect(funding_source.errors[:funding_source]).to include('cannot be made non-billable as it has authorization with service that is not an early code.')
    end
  end
  
  describe 'Assigning payor type' do
    context 'When the payor_type field is assigned the value third_party_contract' do
      let!(:clinic) { create (:clinic)}
      let!(:funding_source) { create(:funding_source, clinic_id: clinic.id, payor_type: 'third_party_contract') }

      it 'The payor type should be equal to the value of the enum in the key 3' do
        expect(funding_source.payor_type).to eq(FundingSource.payor_types.key(3))
      end
    end
  end
end
