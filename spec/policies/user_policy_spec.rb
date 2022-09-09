require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let!(:role1) { create(:role, name: 'super_admin') }
  let!(:user1) { create(:user, :with_role, role_name: role1.name)}
  let!(:role2) { create(:role, name: 'system_administrator') }
  let!(:user2) { create(:user, :with_role, role_name: role2.name)}
  subject { described_class }

  permissions :super_admins_list? do
    it "denies access for roles other than system admin" do
      expect(subject).not_to permit(user1)
    end

    it "grants access to system admin" do
      expect(subject).to permit(user2)
    end
  end

  permissions :create_super_admin? do
    it "denies access for roles other than system admin" do
      expect(subject).not_to permit(user1)
    end

    it "grants access to system admin" do
      expect(subject).to permit(user2)
    end
  end

  permissions :super_admin_detail? do
    it "denies access for roles other than system admin" do
      expect(subject).not_to permit(user1)
    end

    it "grants access to system admin" do
      expect(subject).to permit(user2)
    end
  end

  permissions :update_super_admin? do
    it "denies access for roles other than system admin" do
      expect(subject).not_to permit(user1)
    end

    it "grants access to system admin" do
      expect(subject).to permit(user2)
    end
  end
end
