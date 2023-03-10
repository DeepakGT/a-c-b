require 'rails_helper'
require 'support/render_views'

RSpec.describe ClientNotesController, type: :controller do
  before :each do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  let!(:role) { create(:role, name: 'executive_director', permissions: ['client_notes_view', 'client_notes_update', 'client_notes_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:organization) {create(:organization, name: 'test-organization', admin_id: user.id)}
  let!(:clinic) {create(:clinic, name: 'test-clinic', organization_id: organization.id)}
  let!(:client) { create(:client, clinic_id: clinic.id)}

  describe "GET #index" do
    context "when sign in" do
      let!(:client_notes) { create_list(:client_note, 5, client_id: client.id, creator_id: user.id) }
      it "should fetch client notes list successfully" do
        set_auth_headers(auth_headers)
        
        get :index, params: { client_id: client.id}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(client_notes.count)
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          get :index, params: { client_id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end

      context "when no notes for client is present in database" do
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
      it "should create client note successfully" do
        set_auth_headers(auth_headers)

        post :create, params: {
          client_id: client.id,
          note: 'test-note',
          add_date: Date.today
        }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['note']).to eq('test-note')
      end

      context "when client_id is not present" do
        it "should raise error" do
          set_auth_headers(auth_headers)

          post :create, params: { client_id: 0, id: 0}
          response_body = JSON.parse(response.body)
          
          expect(response_body['errors']).to include("record not found")
        end
      end
    end
  end

  describe "GET #show" do
    context "when sign in" do
      let(:client_note) { create(:client_note, client_id: client.id, creator_id: user.id)}
      it "should fetch client note detail successfully" do
        set_auth_headers(auth_headers)

        get :show, params: {client_id: client.id, id: client_note.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['client_id']).to eq(client.id) 
        expect(response_body['data']['id']).to eq(client_note.id) 
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
      let(:client_note) { create(:client_note, client_id: client.id, creator_id: user.id)}
      let(:updated_note) {'Test-note-1'}
      it "should update client note successfully" do
        set_auth_headers(auth_headers)

        put :update, params: {id: client_note.id, client_id: client.id, note: updated_note}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client_note.id)
        expect(response_body['data']['note']).to eq(updated_note)       
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
      let(:client_note) { create(:client_note, client_id: client.id, creator_id: user.id)}
      it "should delete client note successfully" do
        set_auth_headers(auth_headers)
        delete :destroy, params: {client_id: client.id, id: client_note.id} 
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(client_note.id)
        expect(ClientNote.find_by_id(client_note.id)).to eq(nil)
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
