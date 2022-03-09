require 'rails_helper'

RSpec.describe RolePolicy, type: :policy do
  let!(:user1) { create(:user, :with_role, role_name: 'aba_admin')}
  subject { described_class }

  permissions :index? do
    it "denies access if role is not super_admin" do
      expect(subject).not_to permit(user1)
    end
  end

  permissions :show? do
    it "denies access if role is not super_admin" do
      expect(subject).not_to permit(user1)
    end
  end

  permissions :create? do
    it "denies access if role is not super_admin" do
      expect(subject).not_to permit(user1)
    end
  end

  permissions :update? do
    it "denies access if role is not super_admin" do
      expect(subject).not_to permit(user1)
    end
  end

  permissions :destroy? do
    it "denies access" do
      expect(subject).not_to permit(user1)
    end
  end
end
