require 'rails_helper'
require 'support/render_views'

RSpec.describe ClientEnrollmentServicesController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:role) { create(:role, name: 'aba_admin')}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'test-organization', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'test-clinic', organization_id: organization.id)}
  let!(:client) { create(:client, clinic_id: clinic.id)}
  let!(:staff) { create(:staff, :with_role, role_name: 'bcba', clinics: [clinic])}
  let!(:funding_source) {create(:funding_source, clinic_id: clinic.id)}
  let!(:client_enrollment) { create(:client_enrollment, client_id: client.id, funding_source_id: funding_source.id)}
  let!(:service) { create(:service) }

  describe "POST #create" do
    context "when sign in" do
      it "should create client enrollment service successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {
          client_id: client.id,
          funding_source_id: funding_source.id, 
          service_id: service.id,
          start_date: Date.today,
          end_date: Date.tomorrow,
          staff_id: staff.id
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_enrollment_id']).to eq(client_enrollment.id) 
        expect(response_body['data']['service_id']).to eq(service.id)
        expect(response_body['data']['start_date']).to eq(Date.today.to_s)
        expect(response_body['data']['end_date']).to eq(Date.tomorrow.to_s)
      end
    end
  end
end
