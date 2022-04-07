require 'rails_helper'

RSpec.describe AppointmentPolicy, type: :policy do
  let!(:role1) { create(:role, name: 'aba_admin') }
  let!(:user1) { create(:user, :with_role, role_name: role1.name)}
  let!(:role2) { create(:role, name: 'bcba') }
  let!(:user2) { create(:user, :with_role, role_name: role2.name)}
  let!(:role3) { create(:role, name: 'rbt') }
  let!(:user3) { create(:user, :with_role, role_name: role3.name)}
  subject { described_class }

  permissions :rbt_appointments? do
    it "denies access if permission is not included" do
      expect(subject).not_to permit(user1)
      expect(subject).not_to permit(user2)
    end

    it "grants access if permission is included" do
      expect(subject).to permit(user3)
    end
  end

  permissions :bcba_appointments? do
    it "denies access if permission is not included" do
      expect(subject).not_to permit(user1)
      expect(subject).not_to permit(user3)
    end

    it "grants access if permission is included" do
      expect(subject).to permit(user2)
    end
  end

  permissions :aba_admin_appointments? do
    it "denies access if permission is not included" do
      expect(subject).not_to permit(user2)
      expect(subject).not_to permit(user3)
    end

    it "grants access if permission is included" do
      expect(subject).to permit(user1)
    end
  end
end
