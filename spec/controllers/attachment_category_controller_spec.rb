require 'rails_helper'
require "support/render_views"

RSpec.describe AttachmentCategoriesController, type: :controller do
  before :each do
    request.headers["accept"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:user) { create(:user, :with_role, role_name: 'super_admin') }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:attachment_category_one) {create(:attachment_category)}

  describe "GET #index" do
    context "when sign in" do
      it "should fetch attachment category list successfully" do
        set_auth_headers(auth_headers)

        get :index
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(AttachmentCategory.all.count)
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      it "should fetch attachment category detail successfully" do
        set_auth_headers(auth_headers)

        get :show, params: { id: attachment_category_one.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(attachment_category_one.id)
      end
    end
  end

  describe "POST #create" do
    context "when sign in" do
      it "should add attachment category successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {name: 'Image'}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq('Image')
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let(:attachment_category_two) { create(:attachment_category)}
      it "should update attachment category successfully" do
        set_auth_headers(auth_headers)

        put :update, params: { id: attachment_category_two.id, name: 'ABCD'}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(attachment_category_two.id)
        expect(response_body['data']['name']).to eq("ABCD")
      end

    end
  end


  describe "DELETE #destroy" do
    context "when sign in" do
      let(:user) { create(:user, :with_role, role_name: 'super_admin') }
      let(:auth_headers) { user.create_new_auth_token }
      let(:attachment_category) { create(:attachment_category, name: 'Video')}

      it "should delete attachment category successfully" do
        set_auth_headers(auth_headers)

        delete :destroy, params: { id: attachment_category.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(attachment_category.id)
        expect(AttachmentCategory.find_by_id(attachment_category.id).delete_status).to eq(true)
      end
    end
  end
end
