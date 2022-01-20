require 'rails_helper'
require 'support/render_views'

RSpec.describe ClientEnrollmentsController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  let!(:user) { create(:user, :with_role, role_name: 'aba_admin', first_name: 'admin', last_name: 'user') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'test-organization', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'test-clinic', organization_id: organization.id)}
  let!(:client) { create(:client, :with_role, clinic_id: clinic.id)}
  let!(:funding_source) {create(:funding_source, clinic_id: clinic.id)}

  describe "POST #create" do
    context "when sign in" do
      it "should create client enrollment successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {
          client_id: client.id, 
          funding_source_id: funding_source.id,
          enrollment_date: Date.today,
          insureds_name: 'client2'
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['funding_source_id']).to eq(funding_source.id)
        #expect(response_body['data']['enrollment_date']).to eq(Date.today)
        expect(response_body['data']['insureds_name']).to eq('client2')  
      end
    end
  end
end
