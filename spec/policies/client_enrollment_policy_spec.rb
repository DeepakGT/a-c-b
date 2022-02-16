require 'rails_helper'

RSpec.describe ClientEnrollmentPolicy, type: :policy do
  let!(:role1) { create(:role, name: 'aba_admin') }
  let!(:user1) { create(:user, :with_role, role_name: role1.name)}
  let!(:role2) { create(:role, name: 'administrator', permissions: ['client_source_of_payments_view', 'client_source_of_payments_update', 'client_source_of_payments_delete']) }
  let!(:user2) { create(:user, :with_role, role_name: role2.name)}
  subject { described_class }

  permissions :index? do
    it "denies access if permission is not included" do
      expect(subject).not_to permit(user1)
    end

    it "grants access if permission is included" do
      expect(subject).to permit(user2)
    end
  end

  permissions :show? do
    it "denies access if permission is not included" do
      expect(subject).not_to permit(user1)
    end

    it "grants access if permission is included" do
      expect(subject).to permit(user2)
    end
  end

  permissions :create? do
    it "denies access if permission is not included" do
      expect(subject).not_to permit(user1)
    end

    it "grants access if permission is included" do
      expect(subject).to permit(user2)
    end
  end

  permissions :update? do
    it "denies access if permission is not included" do
      expect(subject).not_to permit(user1)
    end

    it "grants access if permission is included" do
      expect(subject).to permit(user2)
    end
  end

  permissions :destroy? do
    it "denies access if permission is not included" do
      expect(subject).not_to permit(user1)
    end

    it "grants access if permission is included" do
      expect(subject).to permit(user2)
    end
  end
end