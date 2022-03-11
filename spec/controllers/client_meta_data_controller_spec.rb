require 'rails_helper'
require 'support/render_views'

RSpec.describe ClientMetaDataController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'test-organization', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'test-clinic', organization_id: organization.id)}
  let!(:client) { create(:client, clinic_id: clinic.id)}

  describe "GET #selectable_options" do
    context "when sign in" do
      let(:client_enrollments) { client.client_enrollments.active.where.not(source_of_payment: 'self_pay') }
      it "should fetch client selectable options list successfully" do
        set_auth_headers(auth_headers)
        
        get :selectable_options, params: {client_id: client.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['services'].count).to eq(Service.all.count)
        expect(response_body['data']['funding_sources'].count).to eq(client_enrollments.count)
      end
    end
  end

  #let(:service_providers) { clinic.staff.joins(:role).where('role.name': ['bcba', 'rbt']) }
  describe "GET #service_providers_list" do
    context "when sign in" do
      let(:service) { create(:service) }
      let(:service_providers) { clinic.staff.joins(:role).where('role.name': ['bcba', 'rbt']) }
      it "should fetch service providers list successfully." do
        set_auth_headers(auth_headers)

        get :service_providers_list, params: { client_id: client.id, service_id: service.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(service_providers.count)
      end
    end
  end
end
