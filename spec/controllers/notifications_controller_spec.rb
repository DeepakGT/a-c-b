require 'rails_helper'
require 'support/render_views'

RSpec.describe NotificationsController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let!(:user) { create(:user, :with_role, role_name: 'super_admin') }
  let!(:auth_headers) { user.create_new_auth_token }

  describe 'GET #index' do
    let!(:notifications_lists) { create_list(:notification, 3, recipient: user, type: 'UserNotification') }

    context 'when sign in' do
      it 'it returns all notifications in ascending order' do
        set_auth_headers(auth_headers)

        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(notifications_lists.count)
      end
    end
  end

  describe 'GET #index' do
    let!(:notifications_lists) { create_list(:notification, 11, recipient: user, type: 'UserNotification') }

    context 'when the data limit is 10' do
      it 'it returns only the last 10 notifications' do
        set_auth_headers(auth_headers)

        get :index, params: { page: 1, per_page: 10 }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].first['id']).to eq(notifications_lists.last.id)
        expect(response_body['data'].count).to eq(notifications_lists.count - 1)
      end
    end
  end

  describe 'PUT #set_notifications_read' do
    let!(:notifications_lists) { create_list(:notification, 5, recipient: user, type: 'UserNotification') }

    context 'when the parameter ids has values' do
      it 'it updates the read_at field' do
        set_auth_headers(auth_headers)

        put :set_notifications_read, params: { ids:[notifications_lists.first.id] }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['success']).to eq(true)
        expect(Notification.find(notifications_lists.first.id).read_at).not_to eq(nil)
      end
    end

    context 'when ids parameter is empty' do
      it 'it returns error message' do
        set_auth_headers(auth_headers)

        put :set_notifications_read, params: { ids:[] }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(400)
        expect(response_body['success']).to eq(false)
        expect(response_body['error']).to eq('The :ids parameter must have at minimum a valid numeric value')
      end
    end
  end
end
