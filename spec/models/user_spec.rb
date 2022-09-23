require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_one(:user_role).dependent(:destroy)}
    it { should have_one(:rbt_supervision).dependent(:destroy)}
    it { should have_one(:address).dependent(:destroy)}
    it { should have_many(:phone_numbers).dependent(:destroy) } 
    it { should have_one(:role).through(:user_role)}
  end

  it { should accept_nested_attributes_for(:rbt_supervision).update_only(true) }
  it { should accept_nested_attributes_for(:address).update_only(true) }
  it { should accept_nested_attributes_for(:phone_numbers).update_only(true) }

  describe 'enums' do
    it { should define_enum_for(:status)}
    it { should define_enum_for(:gender)}
    it { should define_enum_for(:job_type).backed_by_column_of_type(:string)}     
  end

  describe 'callbacks' do
    it { is_expected.to callback(:assign_role).before(:validation).on(:create) }
  end

  describe "#attr_accessor" do
    let(:user){build :user, :with_role, role_name: 'executive_director'}
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
    let(:user) {build :user, :with_role, role_name: 'executive_director'}
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
      let(:user) { build :user, :with_role, role_name: 'executive_director', status: 'inactive' }
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
    
    let(:user) { create(:user, :with_role, role_name: 'executive_director') }
    let(:organization) { create(:organization, name: 'test-2', admin_id: user.id)}
    it "should be executive_director" do
      expect(Organization.where(admin_id: user.id)).not_to eq(nil)  
    end
  end

  describe "#allow_email_notifications?" do
    context "when user has allowed email notifications" do
      let!(:user) { create(:user, :with_role, role_name: 'administrator') } 
      it "should return true" do
        expect(user.allow_email_notifications?).to eq(true)
      end
    end

    context "when user has disallowed email notifications" do
      let!(:user) { create(:user, :with_role, role_name: 'administrator', deactivated_at: Time.current) } 
      it "should return false" do
        expect(user.allow_email_notifications?).to eq(false)
      end
    end
  end
end
