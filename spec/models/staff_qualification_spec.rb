require 'rails_helper'

RSpec.describe StaffQualification, type: :model do
  let!(:clinic) { create(:clinic, name: 'clinic1') }
  let!(:user) { create(:user, :with_role, role_name: 'rbt', clinic_id: clinic.id) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:qualification) { create(:qualification, lifetime: true)}
  subject { create(:staff_qualification, staff_id: user.id, credential_id: qualification.id)}
  
  describe 'associations' do
    it { should belong_to(:staff).class_name('User')} 
    # it { should belong_to(:qualification).with_foreign_key('credential_id') }
    it { StaffQualification.reflect_on_association(:qualification).macro.should  eq(:belongs_to) } 
  end

  describe 'validations' do
    it { should validate_uniqueness_of(:credential_id).scoped_to(:staff_id)} 
  end

  describe '#validate_expires_at' do
    let(:staff_qualification) { build :staff_qualification, staff_id: user.id, credential_id: qualification.id, expires_at: Date.new}
    context "when lifetime qualification" do
      it "should have blank expires at column" do
        staff_qualification.validate
        expect(staff_qualification.errors[:expires_at]).to include('must be blank for lifetime qualification.')
      end
    end
  end
end
