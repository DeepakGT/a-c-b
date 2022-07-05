require 'rails_helper'

RSpec.describe ClientServiceAddressPolicy, type: :policy do
  let!(:role1) { create(:role, name: 'super_admin') }
  let!(:user1) { create(:user, :with_role, role_name: role1.name)}
  let!(:role2) { create(:role, name: 'administrator') }
  let!(:user2) { create(:user, :with_role, role_name: role2.name)}
  let!(:client) { create(:client)}
  let!(:record1) { create(:address, address_type: 'service_address', addressable_type: 'Client', addressable_id: client.id)}
  let!(:record2) { create(:address, address_type: 'service_address', addressable_type: 'Client', addressable_id: client.id)}
  let!(:service) { create(:service) }
  let!(:client_enrollment) { create(:client_enrollment, client_id: client.id) }
  let!(:client_enrollment_service) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service.id) }
  let!(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, service_address_id: record1.id) }
  subject { described_class }

  permissions :update? do
    it "denies access to all roles except super admin for record that has appointments linked to it" do
      expect(subject).not_to permit(user2, record1)
    end

    it "grants access to super admin to edit all service addresses and all roles to edit addresses that have no linked appointments" do
      expect(subject).to permit(user1, record1)
      expect(subject).to permit(user1, record2)
      expect(subject).to permit(user2, record2)
    end
  end

  permissions :destroy? do
    it "denies access to all users for addresses that have appointments linked" do
      expect(subject).not_to permit(user1, record1)
      expect(subject).not_to permit(user2, record1)
    end

    it "grants access to all users for addresses that have no appointments linked" do
      expect(subject).to permit(user1, record2)
      expect(subject).to permit(user2, record2)
    end
  end
end
