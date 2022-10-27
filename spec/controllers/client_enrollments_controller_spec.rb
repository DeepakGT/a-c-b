require 'rails_helper'
require 'support/render_views'

RSpec.describe ClientEnrollmentsController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:role) { create(:role, name: 'executive_director', permissions: ['client_source_of_payment_view', 'client_source_of_payment_update', 'client_source_of_payment_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'test-organization1', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'test-clinic', organization_id: organization.id)}
  let!(:client) { create(:client, clinic_id: clinic.id)}
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

      it "should fetch the given page record" do
        set_auth_headers(auth_headers)
        
        get :index, params: { client_id: client.id, page: 2}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq("2")
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          get :index, params: { client_id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when no enrollment for client is present in database" do
        let(:client1) { create(:client) }
        it "should display empty list" do
          set_auth_headers(auth_headers)

          get :index, params: { client_id: client1.id}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(0)
        end
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
          group: 'testgroup',
          group_employer: '123456',
          insurance_id: 'xd64758',
          source_of_payment: 'insurance',
          subscriber_dob: '2022-01-01'
        }

        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['funding_source_id']).to eq(funding_source.id)
        expect(response_body['data']['insurance_id']).to eq('xd64758')
        expect(response_body['data']['source_of_payment']).to eq('insurance')
        expect(response_body['data']['group']).to eq('testgroup')
        expect(response_body['data']['group_employer']).to eq('123456')
        expect(response_body['data']['subscriber_dob']).to eq('2022-01-01')
      end

      context "when subscriber dob is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          post :create, params: {
            client_id: client.id, 
            funding_source_id: funding_source.id,
            group: 'testgroup',
            group_employer: '123456',
            insurance_id: 'xd64758',
            source_of_payment: 'insurance'
          }
          response_body = JSON.parse(response.body)

          expect(response_body['errors']).to include("Subscriber dob can't be blank")
        end
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

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          get :show, params: { client_id: 0, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          get :show, params: { client_id: client.id, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let!(:client_enrollment1) { create(:client_enrollment, client_id: client.id, is_primary: true)}
      let!(:client_enrollment) { create(:client_enrollment, client_id: client.id, is_primary: false)}
      let!(:updated_insurance_id) {'VFCD8543'}
      it "should update client enrollment successfully" do
        set_auth_headers(auth_headers)

        put :update, params: {id: client_enrollment.id, client_id: client.id, insurance_id: updated_insurance_id, is_primary: true}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client_enrollment.id)
        expect(response_body['data']['insurance_id']).to eq(updated_insurance_id)       
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          put :update, params: { client_id: 0, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          put :update, params: { client_id: client.id, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
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

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          delete :destroy, params: { client_id: 0, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          delete :destroy, params: { client_id: client.id, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end
    end
  end

  describe "GET #payor_statuses" do
    context "when getting payor statuses" do
      let!(:payor_statuses){ ClientEnrollment.translate_payor_statuses }
      it "should get the selectable options successfully" do
        get :payor_statuses
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['payor_statuses']).to eq(payor_statuses)
      end
    end
  end
end
