require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  it { should have_one(:user_role).dependent(:destroy)}
  it { should have_one(:role).through(:user_role)}

  let!(:user) { create(:user, :with_role, role_name: 'administrator') }
  #let!(:auth_headers) { user.create_new_auth_token }

  describe "#organization" do
    it "should be administrator" do                              
      expect(user.organization).to eq(nil)  
    end    
  end
end
