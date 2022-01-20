require 'rails_helper'
require 'support/render_views'

RSpec.describe AddressesController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:countries) { create_list(:country,5)}
  let!(:country) { create(:country, name: 'United States of America')}
  describe "GET #country_list" do
    context "when sign in" do
      it "should display country list successfully" do
        set_auth_headers(auth_headers)
        
        get :country_list
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(1+countries.count)
      end
    end
  end
end
