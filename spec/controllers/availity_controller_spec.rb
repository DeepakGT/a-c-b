require 'rails_helper'

RSpec.describe AvailityController, type: :controller do
  context "when the user provides a valid api token" do
    it "allows the user to pass" do
      token = Rails.application.credentials[:connect_access_token]
      request.headers.merge!({ "Authorization": "Bearer #{token}" })
      put :update_claim_statuses
      expect(response.status).to eq(200)
    end
  end

  context "when the user provides an invalid api token" do
    it "does not allow the user to pass" do
      token = "invalid123abc"
      request.headers.merge!({ "Authorization": "Bearer #{token}" })
      put :update_claim_statuses
      expect(response.status).to eq(401)
    end
  end

  context "when sending claim statuses request to Availity" do
    it "should return the claim status" do
      rows = [
        %w[CLAIMNUMBER FIRSTNAME LASTNAME FROMDATE PAYOR CLAIMAMOUNT TODATE BIRTHDATE GENDERCODE ACCOUNTNUMBER CORP_TAXID CORP_NPI SUBSCFIRST SUBSCLAST MEMBERID AVAILITY_STATUS],
        ["555555555", "PFirst", "PLast", "6/20/2022", "BLUE CROSS BLUE SHIELD OF FLORIDA", "1000", "6/20/2022", "10/10/2010", "1", "66666666", "777777777", "1568982494", "SFirst", "SLast", "AKA999999999", ""]
      ]
      missing_payerid_errors = []
      claim_status_errors = []
      Availity::ProcessClaimsOperation.process_claims(rows, missing_payerid_errors, claim_status_errors)
      expect(rows[1].last).not_to be nil
    end
  end
end
