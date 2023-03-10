# require 'swagger_helper'
require 'rails_helper'

RSpec.describe Overrides::RegistrationsController, type: :controller do
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @email = "testuser1@yopmail.com"
  end

  describe "POST #create" do
    context "when input valid values" do
      let(:password) { 'Abcd@123' }
      let(:role) { create(:role, name: 'executive_director') }
      let(:clinic) { create(:clinic, name: 'clinic1') }

      it "should create a user" do
        post :create, params: { 
          email: @email,
          password: password,
          confirm_password: password,
          role_id: role.id
        }
        user = JSON.parse(response.body)

        expect(response).to have_http_status :ok
        expect(user["data"]["email"]).to eq(@email)
      end
    end

    context "when input invalid values" do
      it "should fail for invalid email" do
        post :create, params: { 
          email: 'user'
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(422)
        expect(response_body["errors"]).to include("Email is not an email")
      end

      it "should fail for invalid password" do
        post :create, params: { 
          email: @email
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(422)
        expect(response_body["errors"]).to include("Password can't be blank")
      end
    end
  end
end
