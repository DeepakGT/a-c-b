require 'rails_helper'

RSpec.describe Organization, type: :model do
  let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
  subject { create(:organization, name: 'org1', admin_id: user.id)}

  context 'associations' do
    it { should have_one(:address) }
    it { should have_one(:phone_number)}
    it { should have_many(:clinics)}

    it { should accept_nested_attributes_for(:address).update_only(true)}
    it { should accept_nested_attributes_for(:phone_number).update_only(true)}
  end

  it { should define_enum_for(:status)}

  describe 'validations' do
    it { should validate_presence_of(:name) } 
    it { should validate_uniqueness_of(:name) } 
  end
end
