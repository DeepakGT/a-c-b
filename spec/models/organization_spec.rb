require 'rails_helper'

RSpec.describe Organization, type: :model do
  let!(:user) { create(:user, :with_role, role_name: 'executive_director') }
  subject { create(:organization, name: 'org1', admin_id: user.id)}
  let!(:regions) {create_list(:region, 4)}

  it {should belong_to(:admin).class_name('User')}

  context 'associations' do
    it { should have_one(:address).dependent(:destroy) }
    it { should have_one(:phone_number).dependent(:destroy)}
    it { should have_many(:clinics).dependent(:destroy)}

    it { should accept_nested_attributes_for(:address).update_only(true)}
    it { should accept_nested_attributes_for(:phone_number).update_only(true)}
  end

  it { should define_enum_for(:status)}

  describe 'validations' do
    it { should validate_presence_of(:name) } 
    it { should validate_uniqueness_of(:name) } 
  end

  it 'return regions' do
    organization = Organization.create(id_regions: regions.map { |region| region.id })
    expect(organization.regions.count).to eq organization.id_regions.count
  end
end
