require 'rails_helper'

RSpec.describe DeviseTokenAuth::PasswordsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST #create" do
    let(:valid_email) { 'valid_user@yopmail.com' }
    let(:valid_password) { 'Abcd@123' }
    let!(:user) { create(:user, :with_role, email: valid_email, password: valid_password, role_name: 'executive_director') }
    context "when input invalid email" do
      it "should raise error" do
        post :create, params: { 
          email: 'invalid_user@yopmail.com',
          redirect_url: '/'
        }

        expect(response.status).to eq(404)
        expect(user.reload.reset_password_token).not_to be_present
      end
    end

    context "when redirect url is missing" do
      it "should raise error" do
        post :create, params: { 
          email: valid_email
          # redirect_url: '/' (missing)
        }

        expect(response.status).to eq(401)
        expect(user.reload.reset_password_token).not_to be_present
      end
    end

    context "when input valid email" do
      it "should login successfully" do
        post :create, params: { 
          email: valid_email,
          redirect_url: '/'
        }

        expect(response).to have_http_status :ok
        expect(user.reload.reset_password_token).to be_present
      end
    end
  end
end
