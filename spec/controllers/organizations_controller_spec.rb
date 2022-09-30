require 'rails_helper'
require "support/render_views"

RSpec.describe OrganizationsController, type: :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let!(:role) { create(:role, name: 'executive_director', permissions: ['organization_view', 'organization_update'])}
  let!(:role_admin) { create(:role, name: 'super_admin', permissions: ['organization_view', 'organization_update', 'organization_delete'])}
  let!(:user) { create(:user, :with_role, role_name: role.name) }
  let!(:auth_headers) { user.create_new_auth_token }
  let!(:regions_organizations) {create_list(:region, 5)}
  let!(:region) {create(:region)}
  let!(:organization_with_region) { create(:organization, name: 'test-organization', admin_id: user.id, id_regions: regions_organizations.map { |regions_organization| regions_organization.id})}

  describe 'GET #index' do 
    context 'when sign in' do
      let!(:organizations) do
        build_list(:organization, 5) do |organization, i|
          organization.name = "testorg#{i}"
          organization.save!
        end
      end

      it 'should list all organizations' do
        set_auth_headers(auth_headers)
        
        get :index
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(organizations.count + Constant.one)
      end

      it 'should fetch the given page record' do
        set_auth_headers(auth_headers)
        
        get :index, params: { page: 2}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['page']).to eq("2")
      end
    end
  end

  describe 'GET #regions_organizations' do
    context 'when sign in' do
      let!(:organization) { create(:organization, name: 'test-organization', admin_id: user.id, id_regions: regions_organizations.map { |region| region.id})}
      it 'expect list all regions to organizations' do
        set_auth_headers(auth_headers)
        
        get :regions_organizations, params: { id: organization_with_region.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data'].count).to eq(regions_organizations.count)
      end
    end
  end

  describe 'GET #show' do 
    context 'when sign in' do
      it 'expect show organization' do
        set_auth_headers(auth_headers)

        get :show, params: {id: organization_with_region.id}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(organization_with_region.id)
      end
    end
  end
  
  describe 'POST #create' do 
    context 'when sign in' do
      let!(:organization_name){'test-organization-1'}
      let(:address_city) {'Indore'}
      let(:phone_number_type) {'mobile'}
      let(:phone_number) {'8787878787'}
      let!(:id_regions) { regions_organizations.map { |region| region.id } }

      it 'expect create an organization successfully' do
        set_auth_headers(auth_headers)
        
        post :create, params: {
          name: organization_name, 
          address_attributes: {city: address_city}, 
          phone_number_attributes: {phone_type: phone_number_type, number: phone_number},
          id_regions: id_regions

        }
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq(organization_name)
        expect(response_body['data']['address']['city']).to eq(address_city)
        expect(response_body['data']['phone_number']['phone_type']).to eq(phone_number_type) 
        expect(response_body['data']['phone_number']['number']).to eq(phone_number)
        expect(response_body['data']['id_regions'].count).to eq(id_regions.count)
      end
    end
  end

  describe 'PUT #update' do
    let!(:organization) {create(:organization, name: 'organization1', admin_id: user.id, id_regions: regions_organizations.map { |region| region.id })}

    context 'when sign in' do
      let!(:updated_organization_name) {'organization-1-updated'}
      let!(:updated_organization_id_regions) {regions_organizations.map { |region| region.id } }

      it 'should update organization successfully' do
        set_auth_headers(auth_headers)
        
        put :update, params: {id: organization.id, name: updated_organization_name, id_regions: updated_organization_id_regions}
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['name']).to eq(updated_organization_name)
        expect(response_body['data']['id_regions'].count).to eq(updated_organization_id_regions.count)
      end

      let!(:organization) {create(:organization, name: 'organization1', address_attributes: {city: 'Bombay'})}
      let!(:updated_address_city) {'Indore'}
      context 'and update associated data' do
        it 'should update address successfully' do
          set_auth_headers(auth_headers)
          put :update, params: {id: organization.id, address_attributes: {city: updated_address_city} }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['address']['city']).to eq(updated_address_city)
        end

        let!(:updated_phone_number) {'8989898989'}
        it 'should update phone number successfully' do
          set_auth_headers(auth_headers)
          put :update, params: {id: organization.id, phone_number_attributes: {number: updated_phone_number} }
          response_body = JSON.parse(response.body)

          expect(response.status).to eq(200)
          expect(response_body['status']).to eq('success')
          expect(response_body['data']['phone_number']['number']).to eq(updated_phone_number)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when sign in' do
      let(:user) { create(:user, :with_role, role_name: role_admin.name) }
      let(:auth_headers) { user.create_new_auth_token }
      
      it 'should delete organization successfully' do
        set_auth_headers(auth_headers)

        delete :destroy, params: { id: organization_with_region.id }
        response_body = JSON.parse(response.body)

        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['id']).to eq(organization_with_region.id)
        expect(Organization.find_by_id(organization_with_region.id)).to eq(nil)
      end
    end
  end

  describe 'GET #remove_region' do
    context 'when sign in' do
      it 'expect remove region to organization' do
        set_auth_headers(auth_headers)
        
        get :remove_region, params: { id: organization_with_region.id, region: regions_organizations[rand(Constant.five)].id}
        response_body = JSON.parse(response.body)
        
        expect(response.status).to eq(200)
        expect(response_body['status']).to eq('success')
        expect(response_body['data']['organization']['id_regions'].count).to eq(regions_organizations.drop(1).count)
      end
    end
  end
end
