require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe "associations" do
    it { should belong_to(:client) } 
    
    it { should have_one(:address).dependent(:destroy) }
    it { should have_many(:phone_numbers).dependent(:destroy) }
  end

  describe "nested attributes" do
    it { should accept_nested_attributes_for(:address).update_only(true) }
    it { should accept_nested_attributes_for(:phone_numbers).update_only(true) }
  end

  describe "enums" do
    it { should define_enum_for(:relation_type).with_prefix(true) }
    it { should define_enum_for(:relation).with_prefix(true) }
  end

  describe "validations" do
    context "email" do
      subject { build(:contact) }
      it { should validate_uniqueness_of(:email) }
    end
    context "if relation_type is parent/guardian" do
      before { allow(subject).to receive(:parent_or_guardian?).and_return(true) }
      it { should validate_inclusion_of(:parent_portal_access).in_array([true, false]).with_message('must be present.')}
    end
    context "if relation_type is not parent/guardian" do
      before { allow(subject).to receive(:parent_or_guardian?).and_return(false) }
      it { should validate_exclusion_of(:parent_portal_access).in_array([true, false]).with_message('must not be present.')}
    end
  end
end
