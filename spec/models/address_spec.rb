require 'rails_helper'

RSpec.describe Address, type: :model do
  it { should belong_to(:addressable) }
  it { should define_enum_for(:address_type)}

  describe 'validations' do
    context 'when country is USA' do
      let!(:address){ build :address, country: 'United States of America', zipcode: '123456' }
      it 'zipcode must be exact 5 characters long' do
        address.validate
        expect(address.errors[:zipcode]).to include('must be exact 5 characters long.')
      end
    end

    context "when service address is default" do
      let!(:address){ build :address, address_type: 'service_address', is_default: true, is_hidden: true}
      it "should not be hidden" do
        address.validate
        expect(address.errors[:is_hidden]).to include('cannot be true for default address.')
      end
    end

    context "when service address type is present" do
      let!(:service_address_type) {create_list(:service_address_type, 5)}
      let!(:address){ build :address, address_type: 'service_address', service_address_type_id: service_address_type[rand(5)].id, is_default: true, is_hidden: true}

      it "should not be hidden" do
        address.validate
        expect(address.errors[:is_hidden]).to include('cannot be true for default address.')
      end
    end
  end
end
