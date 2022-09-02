require 'rails_helper'
require "support/render_views"

RSpec.describe UsersController, type: :controller do
	before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:user) { create(:user, :with_role, role_name: 'super_admin', first_name: "test user") }
  let!(:auth_headers) { user.create_new_auth_token }

  describe "GET #current_user_detail" do
  	context "when sign in" do
  		it "should fetch current_user_detail successfully" do
  			set_auth_headers(auth_headers)

  			get :current_user_detail
  			response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['first_name']).to eq("test user")
  		end
  	end
  end
  
  describe "PUT #update_default_schedule_view" do
    context "when sign in" do
  		it "should update default schedule view of current user successfully" do
  			set_auth_headers(auth_headers)

  			put :update_default_schedule_view, params: {default_schedule_view: 'list'}
  			response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(user.id)
        expect(response_body['data']['default_schedule_view']).to eq("list")
  		end
  	end
  end

  describe "PUT #email_notifications" do
    context "when sign in" do
      let!(:user1) {create(:user, :with_role, role_name: 'super_admin', deactive_at: nil)}
      it "should allow email notifications for user" do
        set_auth_headers(auth_headers)

        put :email_notifications, params: {user_id: user1.id, deactive_at: Time.current}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(user1.id)
        expect(response_body['data']['deactive_at']).not_to eq(nil)
        expect(response_body['data']['is_email_notification_allowed']).to eq(false)
      end
    end
  end
end
