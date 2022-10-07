require 'rails_helper'
require 'support/render_views'

RSpec.describe AttachmentCategoriesController, type: :controller do
  before :each do
    request.headers["accept"] = 'application/json'
  end

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:user) { create(:user, :with_role, role_name: 'super_admin') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:attachment_category_one) { create(:attachment_category) }

  describe 'GET #index' do
    context 'when sign in' do
      it 'returns the list of attachment categories ' do
        set_auth_headers(auth_headers)

        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(AttachmentCategory.all.count)
      end
    end
  end

  describe 'POST #create' do
    context 'when sign in' do
      it 'Add an attachment category' do
        set_auth_headers(auth_headers)

        post :create, params: { name: 'Image' }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq('image')
      end
    end
  end
end
