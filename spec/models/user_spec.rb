require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_one(:user_role).dependent(:destroy)}
    it { should have_one(:rbt_supervision).dependent(:destroy)}

    it { should have_one(:role).through(:user_role)}
  end

  it { should accept_nested_attributes_for(:rbt_supervision).update_only(true) }

  describe 'enums' do
    it { should define_enum_for(:status)}
    it { should define_enum_for(:gender)}
  end

  describe 'callbacks' do
    it { is_expected.to callback(:assign_role).before(:validation).on(:create) }
  end

  describe "#attr_accessor" do
    let(:user){build :user, :with_role, role_name: 'aba_admin'}
    RSpec::Matchers.define :have_attr_accessor do |role_id|
      match do |user|
        user.respond_to?(role_id) &&
          user.respond_to?("#{role_id}=")
      end
    
      failure_message_for_should do |user|
        "expected attr_accessor for #{role_id} on #{user}"
      end
    
      failure_message_for_should_not do |user|
        "expected attr_accessor for #{role_id} not to be defined on #{user}"
      end
    
      description do
        "checks to see if there is an attr accessor on the supplied object"
      end
    end
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
    context "when user is inactive" do
      let(:user) { build :user, :with_role, role_name: 'aba_admin', status: 'inactive' }
      it "termination date must be present" do
        user.validate
        expect(user.errors[:status]).to include('For an inactive user, terminated date must be present.')
      end
    end
  end

  describe "#organization" do
    let!(:user) { create(:user, :with_role, role_name: 'administrator') } 
    it "should be administrator or super admin" do                             
      expect(user.organization).to eq(nil)  
    end   
    
    let(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let(:organization) { create(:organization, name: 'test-2', admin_id: user.id)}
    it "should be aba_admin" do
      expect(Organization.where(admin_id: user.id)).not_to eq(nil)  
    end
  end
end
