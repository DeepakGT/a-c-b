require 'rails_helper'

RSpec.describe CatalystPolicy, type: :policy do
  let!(:role1) { create(:role, name: 'aba_admin') }
  let!(:user1) { create(:user, :with_role, role_name: role1.name)}
  subject { described_class }

  permissions :sync_with_catalyst? do
    it "denies access if permission is not included" do
      expect(subject).not_to permit(user1)
    end
  end
end
