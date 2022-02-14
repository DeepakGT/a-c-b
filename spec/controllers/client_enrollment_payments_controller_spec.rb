require 'rails_helper'
require 'support/render_views'

RSpec.describe ClientEnrollmentPaymentsController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:role) { create(:role, name: 'aba_admin', permissions: ['client_source_of_payments_view', 'client_source_of_payments_update', 'client_source_of_payments_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'test-organization', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'test-clinic', organization_id: organization.id)}
  let!(:client) { create(:client, clinic_id: clinic.id)}
  let!(:funding_source) {create(:funding_source, clinic_id: clinic.id)}

  describe "GET #index" do
    context "when sign in" do
      let!(:client_enrollment_payments) { create_list(:client_enrollment_payment, 5, client_id: client.id, funding_source_id: funding_source.id) }
      it "should fetch client source of payments list successfully" do
        set_auth_headers(auth_headers)

        get :index, params: { client_id: client.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(client_enrollment_payments.count)
      end
    end
  end
  
  describe "POST #create" do
    context "when sign in" do
      it "should create client source of payment successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {
          client_id: client.id,
          source_of_payment: 'self_pay',
          insurance_id: 'EDCf67754'
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['source_of_payment']).to eq('self_pay')
        expect(response_body['data']['insurance_id']).to eq('EDCf67754')
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:client_enrollment_payment) { create(:client_enrollment_payment, client_id: client.id, funding_source_id: funding_source.id)}
      it "should fetch client source of payment detail successfully" do
        set_auth_headers(auth_headers)

        get :show, params: {client_id: client.id, id: client_enrollment_payment.id}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['id']).to eq(client_enrollment_payment.id) 
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let(:client_enrollment_payment) { create(:client_enrollment_payment, client_id: client.id, funding_source_id: funding_source.id)}
      let(:updated_source_of_payment) {'self_pay'}
      it "should update client source of payment successfully" do
        set_auth_headers(auth_headers)

        put :update, params: {id: client_enrollment_payment.id, client_id: client.id, source_of_payment: updated_source_of_payment}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client_enrollment_payment.id)
        expect(response_body['data']['source_of_payment']).to eq(updated_source_of_payment)       
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      let(:client_enrollment_payment) { create(:client_enrollment_payment, client_id: client.id, funding_source_id: funding_source.id)}
      it "should delete client source of payment successfully" do
        set_auth_headers(auth_headers)
        delete :destroy, params: {client_id: client.id, id: client_enrollment_payment.id} 
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client_enrollment_payment.id)
        expect(ClientNote.find_by_id(client_enrollment_payment.id)).to eq(nil)
      end
    end
  end
end
