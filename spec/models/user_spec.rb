require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_one(:user_role).dependent(:destroy)}
    it { should have_one(:rbt_supervision).dependent(:destroy)}
    it { should have_many(:user_services).dependent(:destroy)}

    it { should have_one(:role).through(:user_role)}
    it { should have_many(:services).through(:user_services)}

    context "when user is admin" do
      subject { build :user, :with_role, role_name: 'aba_admin' }
      it { should belong_to(:clinic).optional } 
    end

    it { should accept_nested_attributes_for(:services).update_only(true) }
    it { should accept_nested_attributes_for(:rbt_supervision).update_only(true) }
  end

  describe 'enums' do
    it { should define_enum_for(:status)}
    it { should define_enum_for(:gender)}
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password).on(:create) }
    it { should validate_length_of(:password).is_at_least(6).is_at_most(128).on(:create) }
    let(:user) {build :user, :with_role, role_name: 'aba_admin'}
    it 'should not allow passwords that do not fit the specified format' do
      invalid_passwords = %w[abcd abcde@12 ABCD@123 Abcd1234 ABCde@@]
      invalid_passwords.each do |invalid_password|
        user.password = invalid_password
        user.validate
        expect(user).to be_invalid
      end
    end
    it { should validate_confirmation_of(:password).on(:create) }
  end

  it { should delegate_method(:name).to(:role).with_prefix(true).allow_nil }

  describe "#validate_status" do
    context "when user is active" do
      let(:user) { build :user, :with_role, role_name: 'aba_admin', status: 'active', terminated_on: Date.new }
      it "termination date should be blank" do
        user.validate
        expect(user.errors[:status]).to include('For an active user, terminated date must be blank.')
      end
    end

    context "when user is inactive" do
      let(:user) { build :user, :with_role, role_name: 'aba_admin', status: 'inactive' }
      it "termination date must be present" do
        user.validate
        expect(user.errors[:status]).to include('For an inactive user, terminated date must be present.')
      end
    end
  end

  describe "#validate_presence_of_clinic" do
    context "when user role is bcba,rbt,billing or client" do
      let(:user) { build :user, :with_role, role_name: 'bcba'}
      it "clinic must be present" do
        user.validate
        expect(user.errors[:clinic]).to include('must be associate with this user.')
      end
    end
  end

  describe "#organization" do
    let(:organization) { create(:organization, name: 'test-1')}
    let!(:clinic) { create(:clinic, name: 'clinic1', organization_id: organization.id) }
    let!(:user) { create(:user, :with_role, role_name: 'administrator') } 
    it "should be administrator" do                             
      expect(user.organization).to eq(nil)  
    end   
    
    let(:user) { create(:user, :with_role, role_name: 'aba_admin', clinic_id: clinic.id) } 
    it "should be aba_admin" do                             
      expect(user.clinic.organization).not_to eq(nil)  
    end   
  end
end
