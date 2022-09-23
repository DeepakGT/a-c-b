require 'rails_helper'
require "support/render_views"

RSpec.describe ClientsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role) { create(:role, name: 'executive_director', permissions: ['clients_view', 'clients_update'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'org1', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'clinic1', organization_id: organization.id, address_attributes: {city: 'Indore'})}

  describe "GET #index" do
    context "when sign in" do
      let!(:clients) { create_list(:client, 4, clinic_id: clinic.id)}
      it "should list client successfully" do
        set_auth_headers(auth_headers)
        
        get :index, :format => :json
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(clients.count)
      end

      it "should fetch the given page record" do
        set_auth_headers(auth_headers)
        
        get :index, params: { page: 2}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq("2")
      end

      context "when no client is present in database" do
        it "should display empty list" do
          Client.destroy_all
          set_auth_headers(auth_headers)

          get :index
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(0)
        end
      end

      context "when default_location_id is present" do
        let!(:clinic1) { create(:clinic) }
        let!(:client_list){ create_list(:client, 7, clinic_id: clinic1.id) }
        it "should filter clients according to location" do
          set_auth_headers(auth_headers)

          get :index, params: {default_location_id: clinic1.id}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(client_list.count)
        end
      end

      context "and filter by logged in user" do
        context "when logged in user is rbt" do
          let!(:role) { create(:role, name: 'rbt', permissions: ['clients_view', 'clients_update'])}
          let!(:staff) { create(:user, :with_role, role_name: role.name) }
          let!(:staff_auth_headers) { staff.create_new_auth_token }
          let!(:client1) { create(:client, clinic_id: clinic.id)}
          let!(:client2) { create(:client, clinic_id: clinic.id)}
          let!(:service) { create(:service) }
          let!(:client_enrollment) { create(:client_enrollment, client_id: client1.id) }
          let!(:client_enrollment_service) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service.id) }
          let!(:schedule) {create(:scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
          it "should display clients that have appointments with rbt" do
            set_auth_headers(staff_auth_headers)

            get :index
            response_body = JSON.parse(response.body)

            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data'].count).to eq(Client.by_staff_id_in_scheduling(staff.id).count)
          end
        end

        context "when logged in user is bcba" do
          let!(:role) { create(:role, name: 'bcba', permissions: ['clients_view', 'clients_update'])}
          let!(:staff) { create(:user, :with_role, role_name: role.name) }
          let!(:staff_auth_headers) { staff.create_new_auth_token }
          let!(:client1) { create(:client, clinic_id: clinic.id)}
          let!(:client2) { create(:client, clinic_id: clinic.id)}
          let!(:client3) { create(:client, clinic_id: clinic.id, primary_bcba_id: staff.id)}
          let!(:service) { create(:service) }
          let!(:client_enrollment) { create(:client_enrollment, client_id: client1.id) }
          let!(:client_enrollment_service) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service.id) }
          let!(:schedule) {create(:scheduling, staff_id: staff.id, client_enrollment_service_id: client_enrollment_service.id)}
          let!(:clients_count) {Client.by_staff_id_in_scheduling(staff.id).or(Client.by_bcbas(staff.id)).count}
          it "should display clients that have appointments with bcba or are under that bcba" do
            set_auth_headers(staff_auth_headers)

            get :index
            response_body = JSON.parse(response.body)

            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data'].count).to eq(clients_count)
          end
        end
      end

      context "and show_inactive checkbox is checked" do
        let!(:client_list1){ create_list(:client, 7, clinic_id: clinic.id, status: 'active') }
        let!(:client_list2){ create_list(:client, 4, clinic_id: clinic.id, status: 'inactive') }
        it "should display inactive clients successfully" do
          set_auth_headers(auth_headers)

          get :index, params: {show_inactive: 1}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(Client.inactive.count)
        end
      end

      context "when search_value is present" do
        let!(:staff) { create(:staff, :with_role, role_name: 'bcba', first_name: 'test', last_name: 'staff') }
        let!(:clients) { create_list(:client, 4, clinic_id: clinic.id, gender: 1, primary_bcba_id: staff.id)}
        let!(:client1) {create(:client, clinic_id: clinic.id, first_name: 'test', gender: 0, payor_status: 'self_pay', primary_bcba_id: nil)}
        let!(:client2) {create(:client, clinic_id: clinic.id, last_name: 'test', gender: 0, payor_status: 'self_pay', primary_bcba_id: nil)}
        let!(:client3) {create(:client, clinic_id: clinic.id, first_name: 'test', last_name: 'client', gender: 0, primary_bcba_id: nil)}
        let!(:funding_source) {create(:funding_source, clinic_id: clinic.id)}
        let!(:client_enrollment1) {create(:client_enrollment, terminated_on: Time.current.to_date+2, funding_source_id: funding_source.id, is_primary: true, client_id: client1.id)}
        let!(:client_enrollment2) {create(:client_enrollment, funding_source_id: funding_source.id, is_primary: false, client_id: client2.id)}
        context "and search_by is present" do
          context "when search_by is name" do
            context "and search_value contains single string" do
              it "should show clients filter by name successfully" do
                set_auth_headers(auth_headers)
                
                get :index, params: { search_by:"name", search_value: "test"}
                response_body = JSON.parse(response.body)
                
                expect(response.status).to eq(200)
                expect(response_body['status']).to eq('success')
                expect(response_body['data'].count).to eq(3)
              end
            end

            context "and search_value contains single string" do
              it "should show clients filter by name successfully" do
                set_auth_headers(auth_headers)
                
                get :index, params: { search_by:"name", search_value: "test client"}
                response_body = JSON.parse(response.body)
                
                expect(response.status).to eq(200)
                expect(response_body['status']).to eq('success')
                expect(response_body['data'].count).to eq(1)
              end
            end
          end

          context "when search_by is gender" do
            it "should list clients filtered by gender successfully" do
              set_auth_headers(auth_headers)

              get :index, params: { search_by:"gender", search_value: "male"}
              response_body = JSON.parse(response.body)

              expect(response.status).to eq(200)
              expect(response_body['status']).to eq('success')
              expect(response_body['data'].count).to eq(Client.by_gender('male').count)
            end
          end

          context "when search_by is payor status" do
            it "should list clients filtered by payor status successfully" do
              set_auth_headers(auth_headers)

              get :index, params: { search_by:"payor_status", search_value: 'insurance'}
              response_body = JSON.parse(response.body)

              expect(response.status).to eq(200)
              expect(response_body['status']).to eq('success')
              expect(response_body['data'].count).to eq(Client.by_payor_status('insurance').count)
            end
          end

          context "when search_by is bcba" do
            it "should list clients filtered by bcba successfully" do
              set_auth_headers(auth_headers)
              
              get :index, params: { search_by: "bcba", search_value: 'test'}
              response_body = JSON.parse(response.body)
              
              expect(response.status).to eq(200)
              expect(response_body['status']).to eq('success')
              expect(response_body['data'].count).to eq(4)
            end

            it "should list clients filtered by bcba successfully" do
              set_auth_headers(auth_headers)
              
              get :index, params: { search_by: "bcba", search_value: 'test staff'}
              response_body = JSON.parse(response.body)
              
              expect(response.status).to eq(200)
              expect(response_body['status']).to eq('success')
              expect(response_body['data'].count).to eq(4)
            end
          end

          context "when search_by is payor" do
            it "should list clients filtered by payor successfully" do
              set_auth_headers(auth_headers)
              
              get :index, params: { search_by:"payor", search_value: funding_source.name}
              response_body = JSON.parse(response.body)
              
              expect(response.status).to eq(200)
              expect(response_body['status']).to eq('success')
              expect(response_body['data'].count).to eq(1)
            end
          end

          context "when search_by is any other value" do
            it "should list all clients successfully" do
              set_auth_headers(auth_headers)
              
              get :index, params: { search_by:"abcd", search_value: funding_source.name}
              response_body = JSON.parse(response.body)
              
              expect(response.status).to eq(200)
              expect(response_body['status']).to eq('success')
              expect(response_body['data'].count).to eq(Client.active.count)
            end
          end
        end

        context "when search_by is absent but search_value is present" do
          it "should list staff filtered by name, gender, payor_status, bcba, payor successfully" do
            set_auth_headers(auth_headers)
            
            get :index, params: { search_value: funding_source.name}
            response_body = JSON.parse(response.body)
            
            expect(response.status).to eq(200)
            expect(response_body['status']).to eq('success')
            expect(response_body['data'].count).to eq(1)
          end
        end
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:client) { create(:client, clinic_id: clinic.id)}
      it "should show client detail successfully" do
        set_auth_headers(auth_headers)

        get :show, params: {id: client.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client.id)
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          get :show, params: { id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end
    end
  end

  describe "POST #create" do
    context "when sign in" do
      it "should create a client successfully" do
        set_auth_headers(auth_headers)

        post :create, params: { 
          clinic_id: clinic.id,
          first_name: 'test',
          last_name: 'client',
          email: 'testcontact@gamil.com',
          payor_status: 'insurance',
          addresses_attributes: [{address_type: 'insurance_address', city: 'Indore'}, 
                                 {address_type: 'service_address', city: 'Delhi'}],
          phone_number_attributes: {phone_type: 'home', number: '99999 99999'}
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['first_name']).to eq('test')
        expect(response_body['data']['addresses'].count).to eq(3)
        expect(response_body['data']['phone_number']['phone_type']).to eq('home')
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let(:client) { 
        create(:client, clinic_id: clinic.id, first_name: 'test', 
               phone_number_attributes: {phone_type: 'home'}, 
               addresses_attributes: [{address_type: 'insurance_address', city: 'Indore'}])
      }
      let(:updated_first_name) {'test-client-1'}
      it "should update a client successfully" do
        set_auth_headers(auth_headers)

        put :update, params: { id: client.id, first_name: updated_first_name }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client.id)
        expect(response_body['data']['first_name']).to eq(updated_first_name)
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          get :show, params: { id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "and update associated data" do
        let(:clinic) {create(:clinic, name: 'clinic', organization_id: organization.id)}
        it "should update associated clinic" do
          set_auth_headers(auth_headers)

          put :update, params: { id: client.id, clinic_id: clinic.id }
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(client.id)
        end

        let(:updated_phone_type) {'mobile'}
        it "should update associated phone number" do
          set_auth_headers(auth_headers)

          put :update, params: { id: client.id, phone_number_attributes: {phone_type: updated_phone_type} }
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(client.id)
          expect(response_body['data']['phone_number']['phone_type']).to eq(updated_phone_type)
        end

        let(:updated_address_type) {'service_address'}
        it "should update associated address" do
          set_auth_headers(auth_headers)

          put :update, params: { id: client.id, addresses_attributes: [{id: client.addresses.first.id, address_type: updated_address_type}] }
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(client.id)
          expect(response_body['data']['addresses'].first['type']).to eq(updated_address_type)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      let(:user) { create(:user, :with_role, role_name: 'super_admin') }
      let(:auth_headers) { user.create_new_auth_token }
      let(:client) { create(:client, clinic_id: clinic.id)}
      it "should delete client successfully" do
        set_auth_headers(auth_headers)

        delete :destroy, params: { id: client.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client.id)
        expect(Client.find_by_id(client.id)).to eq(nil)
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          get :show, params: { id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end
    end
  end

  describe "GET #past_appointments" do
    context "when sign in" do
      let!(:client) { create(:client, clinic_id: clinic.id)}
      let!(:service1) { create(:service) }
      let!(:service2) { create(:service) }
      let!(:funding_source){ create(:funding_source, clinic_id: clinic.id)}
      let!(:client_enrollment) { create(:client_enrollment, client_id: client.id, source_of_payment: 'insurance', funding_source_id: funding_source.id) }
      let!(:client_enrollment_service1) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service1.id) }
      let!(:client_enrollment_service2) { create(:client_enrollment_service, client_enrollment_id: client_enrollment.id, service_id: service2.id) }
      let!(:staff1) { create(:staff, :with_role, role_name: 'administrator', first_name: 'abcd') }
      let!(:staff2) { create(:staff, :with_role, role_name: 'bcba', first_name: 'def') }
      let!(:scheduling1){ create(:scheduling, staff_id: staff1.id, client_enrollment_service_id: client_enrollment_service1.id, date: '2022-01-01') }
      let!(:scheduling2){ create(:scheduling, staff_id: staff2.id, client_enrollment_service_id: client_enrollment_service1.id, date: '2022-01-02') }
      let!(:scheduling3){ create(:scheduling, staff_id: staff2.id, client_enrollment_service_id: client_enrollment_service2.id, date: '2022-01-02') }
      let!(:past_schedules){ Scheduling.joins(client_enrollment_service: :client_enrollment).by_client_ids(client&.id).completed_scheduling }
      it "should show client past appointments successfully" do
        set_auth_headers(auth_headers)

        get :past_appointments, params: {client_id: client.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(past_schedules.count)
      end

      it "should show client past appointments based on page in request params" do
        set_auth_headers(auth_headers)

        get :past_appointments, params: {client_id: client.id, page: 1}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(past_schedules.count)
        expect(response_body['total_records']).to eq(past_schedules.count)
      end

      context "and staff_ids is present in request params" do
        it "should filter past appointments of clients by staff successfully" do
          set_auth_headers(auth_headers)

          get :past_appointments, params: {client_id: client.id, staff_ids: [staff2.id]}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(2)
        end
      end

      context "and service_ids is present in request params" do
        it "should filter past appointments of clients by service successfully" do
          set_auth_headers(auth_headers)

          get :past_appointments, params: {client_id: client.id, service_ids: [service2.id]}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(1)
        end
      end
    end
  end
end
