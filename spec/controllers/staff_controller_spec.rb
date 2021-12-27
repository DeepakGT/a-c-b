require 'rails_helper'
require "support/render_views"

RSpec.describe StaffController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) { create(:organization, name: 'org1', admin_id: user.id) } 
  let!(:clinic) { create(:clinic, name: 'clinic1', organization_id: organization.id) }  

  describe "GET #index" do 
    let!(:staff) { create(:user, :with_role, role_name: 'billing', first_name: 'Jasmie',clinic_id: clinic.id) }   
    context "when sign in" do
      it "should list clinic staff" do
        set_auth_headers(auth_headers)

        get :index, params: {clinic_id: clinic.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].first['first_name']).to eq('Jasmie')
      end
    end
  end

  describe "GET #show" do 
    let!(:staff) { create(:user, :with_role, role_name: 'billing', last_name: 'Zachary',clinic_id: clinic.id) }   
    context "when sign in" do
      it "should fetch clinic staff" do
        set_auth_headers(auth_headers)

        get :show, params: {clinic_id: clinic.id, id: staff.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['last_name']).to eq('Zachary')
      end
    end
  end

  describe "PATCH #update" do 
    let!(:staff) { create(:user, :with_role, role_name: 'administrator', first_name: 'Zachary',clinic_id: clinic.id) }   
    context "when sign in" do
      it "should update clinic staff" do
        set_auth_headers(auth_headers)

        put :update, params: {clinic_id: clinic.id, id: staff.id, first_name: 'testing'}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['first_name']).to eq(nil)
      end
    end
  end

  describe "GET #phone_types" do 
    #let!(:staff) { create(:user, :with_role, role_name: 'billing', last_name: 'Zachary',clinic_id: clinic.id) }   
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
end
