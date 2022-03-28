require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe "associations" do
    it { should belong_to(:client) } 
    
    it { should have_one(:address).dependent(:destroy) }
    it { should have_many(:phone_numbers).dependent(:destroy) }
  end

  describe "#callbacks" do
    it { is_expected.to callback(:set_address).before(:validation) }
  end

  describe "nested attributes" do
    it { should accept_nested_attributes_for(:address).update_only(true) }
    it { should accept_nested_attributes_for(:phone_numbers).update_only(true) }
  end

  describe "enums" do
    it { should define_enum_for(:relation_type).with_prefix(true) }
    it { should define_enum_for(:relation).with_prefix(true) }
  end
  
  describe "#validate_parent_portal_access" do
    context "when relation_type is not parent_or_ guardian, parent_portal_access" do
      let(:contact) { build :contact, relation_type: 'self', parent_portal_access: true }
      it "should be false " do
        contact.validate
        expect(contact.errors[:parent_portal_access]).to include('must be false.')
      end
    end
  end

  # describe "#validate_address" do
  #   context "when is_address_same_as_client is true, contact address" do
  #     let!(:client) { create(:client, addresses_attributes: [{address_type: 'insurance_address', city: 'Indore'}]) }
  #     let(:contact) { build :contact, client_id: client.id, is_address_same_as_client: true, address_attributes: {city: 'Delhi'} }
  #     it "must be absent" do
  #       contact.validate
  #       expect(contact.errors[:address]).to include('must be absent when contact have same address as client.')
  #     end
  #   end
  end
end
