require 'rails_helper'

RSpec.describe DeviseTokenAuth::SessionsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST #create" do
    context "when input invalid credentials" do
      it "should not login" do
        post :create, params: { 
          email: 'invalid_user@yopmail.com',
          password: 'invalid_password'
        }

        expect(response.status).to eq(401)
        expect(subject.current_user).to be_nil
      end
    end

    context "when input valid credentials" do
      let(:valid_email) { 'valid_user@yopmail.com' }
      let(:valid_password) { '123456' }
      let!(:user) { create(:user, :with_role, email: valid_email, password: valid_password, role_name: 'aba_admin') }
      it "should login successfully" do
        post :create, params: { 
          email: valid_email,
          password: valid_password
        }

        expect(response).to have_http_status :ok
        expect(subject.current_user.id).to eq(user.id)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
    let!(:auth_headers) { user.create_new_auth_token }

    context "when sign out" do
      it "should logout successfully" do
        set_auth_headers(auth_headers)
        delete :destroy
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['success']).to eq(true)
      end

      it "should not logout" do
        delete :destroy
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(404)
        expect(response_body['success']).to eq(false)
        expect(response_body['errors']).to include('User was not found or was not logged in.')
      end
    end
  end
end
