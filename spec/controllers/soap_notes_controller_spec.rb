require 'rails_helper'
require 'support/render_views'

RSpec.describe SoapNotesController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role) { create(:role, name: 'aba_admin', permissions: ['soap_notes_view', 'soap_notes_update', 'soap_notes_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) { create(:organization, name: 'org1') }
  let!(:clinic) { create(:clinic, name: 'clinic1', organization_id: organization.id) }
  let!(:client) { create(:client, clinic_id: clinic.id) }
  let!(:service) { create(:service) }
  let!(:staff) { create(:staff, :with_role, role_name: 'bcba') }
  let!(:scheduling) { create(:scheduling, client_id: client.id, staff_id: staff.id, service_id: service.id) }

  describe "GET #index" do
    context "when sign in" do
      let!(:soap_notes) { create_list(:soap_note, 5, scheduling_id: scheduling.id)}
      it "should fetch soap notes list successfully" do
        set_auth_headers(auth_headers)

        get :index, params: { scheduling_id: scheduling.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(soap_notes.count)
      end
    end
  end
  
  describe "POST #create" do
    context "when sign in" do
      it "should create soap note successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {
          scheduling_id: scheduling.id,
          note: 'test-note-1',
          add_date: Time.now.to_date
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['scheduling_id']).to eq(scheduling.id)
        expect(response_body['data']['note']).to eq('test-note-1')
        expect(response_body['data']['add_date']).to eq(Time.now.to_date.to_s)
      end
    end
  end
end