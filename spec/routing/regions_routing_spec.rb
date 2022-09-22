require 'rails_helper'

RSpec.describe RegionsController, type: :routing do
  let!(:region) { create(:region) }

  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/regions').to route_to('regions#index')
    end

    it 'routes to #create' do
      expect(post: '/api/regions').to route_to('regions#create')
    end

    it 'routes to #update' do
      expect(patch: "/api/regions/#{region.id}").to route_to(controller: 'regions', action: 'update', id: region.id.to_s)
    end
  end
end
