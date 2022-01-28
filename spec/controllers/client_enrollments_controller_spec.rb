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

  describe "GET #index" do
    context "when sign in" do
      let!(:client_enrollments) { create_list(:client_enrollment, 4, client_id: client.id)}
      it "should fetch client enrollment list successfully" do
        set_auth_headers(auth_headers)

        get :index, params: { client_id: client.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(client_enrollments.count)      
      end 

      it "should fetch the first page record by default" do
        set_auth_headers(auth_headers)
        
        get :index, params: { client_id: client.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq(1)
      end

      it "should fetch the given page record" do
        set_auth_headers(auth_headers)
        
        get :index, params: { client_id: client.id, page: 2}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq("2")
      end
    end
  end
  
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
        expect(response_body['data']['enrollment_date']).to eq(Date.today.to_s)
        expect(response_body['data']['insureds_name']).to eq('client2')  
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:client_enrollment) { create(:client_enrollment, client_id: client.id)}
      it "should show client enrollment detail successfully" do
        set_auth_headers(auth_headers)

        get :show, params: {client_id: client.id, id: client_enrollment.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['id']).to eq(client_enrollment.id) 
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let(:client_enrollment) { create(:client_enrollment, client_id: client.id)}
      let(:updated_insureds_name) {'Test-insured-1'}
      it "should update client enrollment successfully" do
        set_auth_headers(auth_headers)

        put :update, params: {id: client_enrollment.id, client_id: client.id, insureds_name: updated_insureds_name}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client_enrollment.id)
        expect(response_body['data']['insureds_name']).to eq(updated_insureds_name)       
      end

      context "and update associated data" do
        it "should update associated funding source successfully" do
          set_auth_headers(auth_headers)
          
          put :update, params: {id: client_enrollment.id, client_id: client.id, funding_source_id: funding_source.id}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(client_enrollment.id)
          expect(response_body['data']['funding_source_id']).to eq(funding_source.id)       
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      let(:client_enrollment) { create(:client_enrollment, client_id: client.id)}
      it "should delete client enrollment successfully" do
        set_auth_headers(auth_headers)
        delete :destroy, params: {client_id: client.id, id: client_enrollment.id} 
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client_enrollment.id)
        expect(ClientEnrollment.find_by_id(client_enrollment.id)).to eq(nil)
      end
    end
  end
end
