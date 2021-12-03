require 'rails_helper'

RSpec.describe ClinicsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  describe "GET #index" do
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }

    before do
      create(:organization, name: 'org1', admin_id: user.id)
    end
    context "when sign in" do
      it "should fetch client list successfully" do
        request.headers['Uid'] = auth_headers['uid']
        request.headers['Access-Token'] = auth_headers['access-token']
        request.headers['Client'] = auth_headers['client']
        
        get :index, params: {organization_id: 1} 
        # response_body = JSON.parse(response.body)
        # assigns(:clinics)

        expect(response.status).to eq(200)
        expect(response_body['success']).to eq(true)
      end
    end
  end
end
