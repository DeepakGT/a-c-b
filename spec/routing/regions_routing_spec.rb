require "rails_helper"

RSpec.describe RegionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/regions").to route_to("regions#index")
    end
  end
end
