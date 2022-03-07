require 'rails_helper'

RSpec.describe StaffCredential, type: :model do
  let!(:clinic) { create(:clinic, name: 'clinic1') }
  let!(:user) { create(:user, :with_role, role_name: 'rbt', clinic_id: clinic.id) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:credential) { create(:credential, lifetime: true)}
  subject { create(:staff_credential, staff_id: user.id, credential_id: credential.id)}
  
  describe 'associations' do
    it { should belong_to(:staff).class_name('User')} 
  end

  describe 'validations' do
    it { should validate_uniqueness_of(:credential_id).scoped_to(:staff_id)} 
  end

  describe '#validate_expires_at' do
    let(:staff_credential) { build :staff_credential, staff_id: user.id, credential_id: credential.id, expires_at: Date.new}
    context "when lifetime credential" do
      it "should have blank expires at column" do
        staff_credential.validate
        expect(staff_credential.errors[:expires_at]).to include('must be blank for lifetime credential.')
      end
    end
  end
end
