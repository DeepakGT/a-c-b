require 'rails_helper'
require "support/render_views"

RSpec.describe StaffController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role_admin) { create(:role, name: 'executive_director', permissions: ['staff_view', 'staff_update', 'staff_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role_admin.name, first_name: 'admin', last_name: 'user') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) { create(:organization, name: 'test org', admin_id: user.id) } 
  let!(:role) { create(:role, name: 'bcba')}
  let!(:clinic) { create(:clinic, name: 'clinic1', organization_id: organization.id) }  

  describe "GET #index" do 
    context "when sign in" do
      before do
        ["Test1","Test2"].map do |first_name| 
          create(:staff, :with_role, role_name: 'billing', first_name: first_name, 
                  address_attributes: {city: 'Indore'}, supervisor_id: user.id) 
        end
      end

      it "should list staff successfully" do
        set_auth_headers(auth_headers)

        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Staff.joins(:role).by_role('billing').count)
      end

      it "should fetch the given page record" do
        set_auth_headers(auth_headers)
        
        get :index, params: { page: 2}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq("2")
      end

      context "when show_inactive is selected" do
        let(:staff) {create(:staff, :with_role, role_name: 'billing', status: 'inactive')}
        it "should display inactive staff only" do
          set_auth_headers(auth_headers)
        
          get :index, params: { page: 1, show_inactive: 1}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(Staff.inactive.count)
        end
      end

      context "when search_by is name" do
        it "should staff filter by name successfully" do
          set_auth_headers(auth_headers)
          
          get :index, params: { search_by:"name", search_value: "test1"}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(1)
          expect(response_body['data'].first['first_name'].downcase).to eq('test1')  
        end

        let!(:staff){create(:staff, :with_role, role_name: 'bcba', first_name: 'test', last_name: 'staff')}
        it "should staff filter by name successfully" do
          set_auth_headers(auth_headers)
          
          get :index, params: { search_by:"name", search_value: "test staff"}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(1)
          expect(response_body['data'].first['first_name'].downcase).to eq('test')  
          expect(response_body['data'].first['last_name'].downcase).to eq('staff')  
        end
      end

      context "when search_by is role" do
        it "should list staff filtered by role successfully" do
          set_auth_headers(auth_headers)

          get :index, params: { search_by:"role", search_value: "billing"}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(2)
          expect(response_body['data'].first['title']).to eq('billing')  
        end
      end

      context "when search_by is organization" do
        it "should list staff filtered by organization successfully" do
          set_auth_headers(auth_headers)

          get :index, params: { search_by:"organization", search_value: organization.name}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(Staff.joins(clinics: :organization).by_organization(organization.name).count)
        end
      end

      context "when search_by is location" do
        it "should list staff filtered by location successfully" do
          set_auth_headers(auth_headers)
          
          get :index, params: { search_by:"location", search_value: 'Indore'}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(2)
        end
      end

      context "when search_by is immediate_supervisor" do
        it "should list staff filtered by supervisor successfully" do
          set_auth_headers(auth_headers)
          
          get :index, params: { search_by:"immediate_supervisor", search_value: 'admin user'}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(2)
          expect(response_body['data'].first['supervisor_id']).to eq(user.id)
        end

        it "should list staff filtered by supervisor successfully" do
          set_auth_headers(auth_headers)
          
          get :index, params: { search_by:"immediate_supervisor", search_value: 'admin'}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(2)
          expect(response_body['data'].first['supervisor_id']).to eq(user.id)
        end
      end

      context "when search_by is other than name, organization, immediate_supervisor, role, location" do
        it "should display all staff" do
          set_auth_headers(auth_headers)
          
          get :index, params: { search_by: "abcd", search_value: 'admin'}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(Staff.active.count)
        end
      end

      context "when search_by is absent but search_value is present" do
        it "should list staff filtered by name, role, location, organization, supervisor successfully" do
          set_auth_headers(auth_headers)
          
          get :index, params: { search_value: 'admin user'}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(2)
        end

        it "should list staff filtered by name, role, location, organization, supervisor successfully" do
          set_auth_headers(auth_headers)
          
          get :index, params: { search_value: 'bcba'}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(Staff.joins(:role).by_role('bcba').count)
        end
      end

      context "when default_location_id is present" do
        let!(:staff_clinic1) { create(:staff_clinic, staff_id: Staff.first.id, clinic_id: clinic.id, is_home_clinic: true) }
        let!(:staff_clinic2) { create(:staff_clinic, staff_id: Staff.last.id, clinic_id: clinic.id, is_home_clinic: true) }
        it "should list staff filtered by location successfully" do
          set_auth_headers(auth_headers)
          
          get :index, params: { default_location_id: clinic.id}
          response_body = JSON.parse(response.body)
      
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(2)
        end
      end
    end
  end

  describe "GET #show" do 
    let!(:staff) { create(:staff, :with_role, role_name: 'billing', last_name: 'Zachary') }   
    context "when sign in" do
      it "should fetch clinic staff" do
        set_auth_headers(auth_headers)

        get :show, params: {id: staff.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(staff.id)  
        expect(response_body['data']['last_name']).to eq('Zachary')
      end
    end
  end

  describe "POST #create" do
    context "when sign in" do
      it "should create staff successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {
          first_name: 'test',
          last_name: 'staff',
          email: 'bcba_test@yopmail.com',
          password: 'Abcd@123',
          supervisor_id: user.id,
          clinic_id: clinic.id,
          address_attributes: { country: 'India'},
          phone_numbers_attributes: [{ number: '9898767655'}, {number: '8787876565'}],
          rbt_supervision_attributes: { status: 'requires'},
          role_name: 'bcba',
          npi: '0123456789',
          staff_location_id: clinic.id,
          legacy_number: '6758399746578493'
        }
        
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['supervisor_id']).to eq(user.id)
        expect(response_body['data']['email']).to eq('bcba_test@yopmail.com')
        expect(response_body['data']['role']).to eq('bcba')
        expect(response_body['data']['address']['country']).to eq('India')
        expect(response_body['data']['phone_numbers'].count).to eq(2)
        expect(response_body['data']['rbt_supervision']['status']).to eq('requires')
        expect(response_body['data']['npi']).to eq('0123456789')
        expect(response_body['data']['staff_clinics']).not_to eq(nil)
        expect(response_body['data']['staff_clinics'].count).to eq(1)
        expect(response_body['data']['legacy_number']).to eq('6758399746578493')
      end
    end
  end

  describe "PUT #update" do 
    let!(:staff) { create(:staff, :with_role, role_name: 'bcba', first_name: 'Zachary') }   
    context "when sign in" do
      it "should update staff successfully" do
        set_auth_headers(auth_headers)

        put :update, params: {id: staff.id, first_name: 'testing'}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(staff.id)
      end

      it "should update password if present in request" do
        set_auth_headers(auth_headers)

        put :update, params: {id: staff.id, password: 'Abcde@123', password_confirmation: 'Abcde@123'}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(staff.id)
      end

      context "and update associated data" do
        let(:role) { create(:role, name: 'billing')}
        it "should update role successfully" do
          set_auth_headers(auth_headers)

          put :update, params: {role_name: 'billing', id:staff.id}
          response_body = JSON.parse(response.body)
          
          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(staff.id)
        end

        let(:clinic) { create(:clinic, name: 'clinic2', organization_id: organization.id) }
        it "should update clinic successfully" do
          set_auth_headers(auth_headers)

          put :update, params: {clinic_id: clinic.id, id:staff.id}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(staff.id)
        end

        it "should update address successfully" do
          set_auth_headers(auth_headers)

          put :update, params: {id:staff.id, address_attributes: {city: 'Indore'}}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(staff.id)
        end

        it "should update phone number successfully" do
          set_auth_headers(auth_headers)

          put :update, params: {id:staff.id, phone_numbers_attributes: [{number: '9876678900'}]}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(staff.id)
        end

        it "should update rbt supervision successfully" do
          set_auth_headers(auth_headers)

          put :update, params: {id:staff.id, rbt_supervision_attributes: {status: 'provides'}}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(staff.id)
        end

        it "should update service successfully" do
          set_auth_headers(auth_headers)

          put :update, params: {
            id:staff.id,
            services_attributes: [{name: 'service-1'}]
          }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['id']).to eq(staff.id)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      let!(:staff) { create(:staff, :with_role, role_name: 'billing', last_name: 'Zachary') }   
      it "should delete staff successfully" do
        set_auth_headers(auth_headers)

        delete :destroy, params: {id: staff.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(staff.id)
        expect(Staff.find_by_id(staff.id)).to eq(nil)
      end
    end
  end

  describe "GET #phone_types" do 
    context "when sign in" do
      it "should fetch all phone types" do
        set_auth_headers(auth_headers)

        get :phone_types
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].map{|hash| hash['type']}).to match_array PhoneNumber.phone_types.keys
        expect(response_body['data'].map{|hash| hash['id'] }).to match_array PhoneNumber.phone_types.values
        expect(response_body['data']).to be_a_kind_of(Array)
      end
    end
  end
    
  describe "GET #supervisor_list" do
    let!(:staff_list) { create_list(:staff, 5, :with_role, role_name: 'billing', clinics: [clinic])}
    context "when sign in" do
      it "should list supervisors successfuly" do
        set_auth_headers(auth_headers)

        get :supervisor_list
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Staff.all.count)
      end
    end
  end

  describe 'GET #gender_list' do

    context 'when sign in' do
      it "expect list genders successfuly" do
        set_auth_headers(auth_headers)

        get :gender_list
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(Staff.genders.count)
      end
    end
  end
end
