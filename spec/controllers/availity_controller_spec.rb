require 'rails_helper'

RSpec.describe AvailityController, type: :controller do
  context "when sending claim statuses request to Availity with an invalid token" do
    it "should return forbidden error" do
      token = "invalid123abc"
      request.headers.merge!({ "Authorization": "Bearer #{token}" })
      put :update_claim_statuses, params: {
        bucket: "unloadingsnf-dev",
        source_file: "availity/collab-pending-availity.csv",
        target_file: "availity/collab-availity-done.csv"
      }
      expect(response.status).to eq(401)
    end
  end

  context "when sending claim statuses request to Availity with a valid token" do
    it "should return http success" do
      token = Rails.application.credentials[:connect_access_token]
      request.headers.merge!({ "Authorization": "Bearer #{token}" })
      put :update_claim_statuses, params: {
        bucket: "unloadingsnf-dev",
        source_file: "availity/collab-pending-availity.csv",
        target_file: "availity/collab-availity-done.csv"
      }
      expect(response.status).to eq(200)
    end
  end
end
