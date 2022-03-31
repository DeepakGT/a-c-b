require 'rails_helper'
require 'support/render_views'

RSpec.describe ClientAttachmentsController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:role) { create(:role, name: 'aba_admin', permissions: ['client_files_view', 'client_files_update', 'client_files_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'test-organization', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'test-clinic', organization_id: organization.id)}
  let!(:client) { create(:client, clinic_id: clinic.id)}

  describe "GET #index" do
    context "when sign in" do
      let!(:client_attachments) { create_list(:attachment, 5, attachable_id: client.id, attachable_type: 'User') }
      it "should fetch client attachments list successfully" do
        set_auth_headers(auth_headers)

        get :index, params: { client_id: client.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(client_attachments.count)
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          get :index, params: { client_id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when no attachment for client is present in database" do
        let(:client1) { create(:client) }
        it "should display empty list" do
          set_auth_headers(auth_headers)

          get :index, params: { client_id: client1.id}
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data'].count).to eq(0)
        end
      end
    end
  end
  
  describe "POST #create" do
    context "when sign in" do
      it "should create client attachment successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {
          client_id: client.id,
          category: 'image',
          base64: 'data:image/gif;base64,R0lGODdhAQABAPAAAP8AAAAAACwAAAAAAQABAAACAkQBADs=',
          file_name: 'test-file'
        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['category']).to eq('image')
        expect(response_body['data']['url']).not_to eq(nil)
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          post :create, params: { client_id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:client_attachment) { create(:attachment, attachable_id: client.id, attachable_type: 'User', category: 'image')}
      it "should fetch client attachment detail successfully" do
        set_auth_headers(auth_headers)

        get :show, params: {client_id: client.id, id: client_attachment.id}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['id']).to eq(client_attachment.id) 
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          get :show, params: { client_id: 0, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          get :show, params: { client_id: client.id, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end
    end
  end

  describe "PUT #update" do
    context "when sign in" do
      let(:client_attachment) { create(:attachment, attachable_id: client.id, attachable_type: 'User', category: 'image')}
      let(:updated_category) { 'png' }
      it "should update client attachment successfully" do
        set_auth_headers(auth_headers)

        put :update, params: {id: client_attachment.id, client_id: client.id, category: updated_category}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client_attachment.id)
        expect(response_body['data']['category']).to eq(updated_category)       
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          put :update, params: { client_id: 0, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          put :update, params: { client_id: client.id, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "when sign in" do
      let(:client_attachment) { create(:attachment, attachable_id: client.id, attachable_type: 'User', category: 'image')}
      it "should delete client attachment successfully" do
        set_auth_headers(auth_headers)
        delete :destroy, params: {client_id: client.id, id: client_attachment.id} 
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client_attachment.id)
        expect(ClientNote.find_by_id(client_attachment.id)).to eq(nil)
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          delete :destroy, params: { client_id: 0, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          delete :destroy, params: { client_id: client.id, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end
    end
  end
end
