require 'rails_helper'
require 'support/render_views'

RSpec.describe MetaDataController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:user) { create(:user, :with_role, role_name: 'aba_admin') }
  let!(:auth_headers) { user.create_new_auth_token }

  describe "GET #selectable_options" do
    let!(:country_lists) { create_list(:country,6)}
    let!(:country) { create(:country, name: 'United States of America')}
    context "when sign in" do
      it "should fetch selectable options list successfully" do
        set_auth_headers(auth_headers)
        
        get :selectable_options
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['payer_statuses'].count).to eq(Client.payer_statuses.count)
        expect(response_body['data']['preferred_languages'].count).to eq(Client.preferred_languages.count)
        expect(response_body['data']['dq_reasons'].count).to eq(Client.dq_reasons.count)
        expect(response_body['data']['relation_types'].count).to eq(Contact.relation_types.count)
        expect(response_body['data']['relations'].count).to eq(Contact.relations.count)
        expect(response_body['data']['credential_types'].count).to eq(Credential.credential_types.count)
        expect(response_body['data']['roles'].count).to eq(Role.all.count)
        expect(response_body['data']['phone_types'].count).to eq(PhoneNumber.phone_types.count)
        expect(response_body['data']['country_list'].count).to eq(country_lists.count+1)
      end
    end
  end
end