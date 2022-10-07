require 'rails_helper'
require 'support/render_views'
RSpec.describe RegionsController, type: :controller do
  let!(:role) { create(:role, name: Constant.role['super_admin'], permissions: ['regions_view', 'regions_update']) }
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:regions) { create_list(:region, 4) }

  describe 'GET #index' do
    context 'when sign in' do
      it 'expect fetch regions list successfully' do
        set_auth_headers(auth_headers)
        get :index, format: :json
        response_body = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(regions.count) 
      end
    end
  end

  describe 'POST #create' do 
    context 'when sign in' do
      it 'expect create an regions successfully' do
        set_auth_headers(auth_headers)
        post :create, format: :json, params: { name: 'test' }
        response_body = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
      end
    end
  end

  describe 'POST #update' do 
    let!(:region) { create(:region) }

    context 'when sign in' do
      it 'expect update an regions successfully' do
        set_auth_headers(auth_headers)
        patch :update, format: :json, params: {id: region.id, name: 'test2' }
        response_body = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(region.id)
      end
    end
  end
end
