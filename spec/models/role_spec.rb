require 'rails_helper'

RSpec.describe Role, type: :model do
  
  describe 'associations' do
    it { should have_many(:user_roles).dependent(:destroy)}
    it { should have_many(:users).through(:user_roles)}
  end

  it do
    should define_enum_for(:name)
      .with_values(
        aba_admin: 'aba admin',
        administrator: 'administrator',
        bcba: 'bcba',
        rbt: 'rbt',
        billing: 'billing',
        client: 'client'
      )
      .backed_by_column_of_type(:string)
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
