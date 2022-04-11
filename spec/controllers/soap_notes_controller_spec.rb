require 'rails_helper'
require 'support/render_views'

RSpec.describe SoapNotesController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role) { create(:role, name: 'executive_director', permissions: ['soap_notes_view', 'soap_notes_update', 'soap_notes_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) { create(:organization, name: 'org1', admin_id: user.id) }
  let!(:clinic) { create(:clinic, name: 'clinic1', organization_id: organization.id) }
  let!(:client) { create(:client, clinic_id: clinic.id) }
  let!(:client_enrollment) { create(:client_enrollment, client_id: client.id) }
  let!(:service) { create(:service) }
  let!(:client_enrollment_service) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service.id) }
  let!(:staff) { create(:staff, :with_role, role_name: 'bcba') }
  let!(:scheduling) { create(:scheduling, client_enrollment_service_id: client_enrollment_service.id, staff_id: staff.id, units: '2') }

  describe "GET #index" do
    context "when sign in" do
      let!(:soap_notes) { create_list(:soap_note, 5, scheduling_id: scheduling.id, user: user)}
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

  describe "GET #show" do
    context "when sign in" do
      let(:soap_note) { create(:soap_note, scheduling_id: scheduling.id, note: 'test-note', add_date: '2022-02-28', user: user) }
      it "should fetch soap note detail successfully" do
        set_auth_headers(auth_headers)

        get :show, params: { scheduling_id: scheduling.id, id: soap_note.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(soap_note.id)
        expect(response_body['data']['scheduling_id']).to eq(scheduling.id)
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

  describe "PUT #update" do
    context "when sign in" do
      let(:soap_note) { create(:soap_note, scheduling_id: scheduling.id, note: 'test-note-1', add_date: '2022-02-28', user: user) }
      it "should update soap note detail successfully" do
        set_auth_headers(auth_headers)

        put :update, params: { scheduling_id: scheduling.id, id: soap_note.id, note: 'test-note', add_date: '2022-03-02' }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(soap_note.id)
        expect(response_body['data']['scheduling_id']).to eq(scheduling.id)
        expect(response_body['data']['note']).to eq('test-note')
        expect(response_body['data']['add_date']).to eq('2022-03-02')
      end

      context "when user tries to update signature" do
        let(:rbt_role){ create(:role, name: 'rbt', permissions: ['soap_notes_update'])}
        let(:staff){ create(:staff, :with_role, role_name: rbt_role.name)}
        let(:staff_auth_headers){ staff.create_new_auth_token }
        it "should update signatures successfully" do
          set_auth_headers(staff_auth_headers)
  
          put :update, params: { scheduling_id: scheduling.id, rbt_sign: true, id: soap_note.id }
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(soap_note.id)
          expect(response_body['data']['scheduling_id']).to eq(scheduling.id)
          expect(response_body['data']['rbt_sign']).to eq(true)
          expect(response_body['data']['rbt_sign_name']).to eq("#{user.first_name} #{user.last_name}")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      let(:soap_note) { create(:soap_note, scheduling_id: scheduling.id, note: 'test-note', add_date: '2022-02-28', user: user) }
      it "should fetch soap note detail successfully" do
        set_auth_headers(auth_headers)

        delete :destroy, params: { scheduling_id: scheduling.id, id: soap_note.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(soap_note.id)
        expect(response_body['data']['scheduling_id']).to eq(scheduling.id)
        expect(SoapNote.find_by_id(soap_note.id)).to eq(nil)
      end
    end
  end
end
