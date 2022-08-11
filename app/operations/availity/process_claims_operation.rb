module Availity
  module ProcessClaimsOperation
    AVAILITY_LOG_PATH = "log/availity".freeze
    AVAILITY_STATUS = "AVAILITY_STATUS".freeze
    CLAIM_NUMBER = "CLAIMNUMBER".freeze
    PAYOR = "PAYOR".freeze
    
    class << self
      def process_claims(rows, missing_payerid_errors, claim_status_errors)
        # mapping between between Availity API parameters and S3 data fields
        # TODO: make this configurable
        field_mapping_list = [
          { availity_param: "payer.id", data_field: PAYOR },
          { availity_param: "providers.npi", data_field: "CORP_NPI" },
          { availity_param: "providers.taxId", data_field: "CORP_TAXID" },
          { availity_param: "fromDate", data_field: "FROMDATE" },
          { availity_param: "toDate", data_field: "TODATE" },
          { availity_param: "patient.lastName", data_field: "LASTNAME" },
          { availity_param: "patient.firstName", data_field: "FIRSTNAME" },
          { availity_param: "patient.birthDate", data_field: "BIRTHDATE" },
          { availity_param: "patient.genderCode", data_field: "GENDERCODE" },
          { availity_param: "patient.accountNumber", data_field: "ACCOUNTNUMBER" },
          { availity_param: "subscriber.memberId", data_field: "MEMBERID" },
          { availity_param: "subscriber.lastName", data_field: "SUBSCLAST" },
          { availity_param: "subscriber.firstName", data_field: "SUBSCFIRST" },
          { availity_param: "claimNumber", data_field: CLAIM_NUMBER },
          { availity_param: "claimAmount", data_field: "CLAIMAMOUNT" }
        ]

        # mapping between CollabMD Payors and Availity Payer Ids
        # need data from billing department to complete this mapping
        # TODO: make this configurable
        payer_mapping = {
          "BLUE CROSS BLUE SHIELD OF FLORIDA" => {
            availity_payer_id: "BCBSF",
            provider_submitter_id: "",
            submitter_last_name: "ABA CENTERS OF AMERICA",
            provider_last_name: "ABA CENTERS OF AMERICA"
          },
          "UNICARE" => {
            availity_payer_id: "UNI",
            provider_submitter_id: "",
            submitter_last_name: "ABA CENTERS OF AMERICA",
            provider_last_name: "ABA CENTERS OF AMERICA"
          },
          "UMR" => {
            availity_payer_id: "UMR",
            provider_submitter_id: "",
            submitter_last_name: "ABA CENTERS OF AMERICA",
            provider_last_name: "ABA CENTERS OF AMERICA"
          }
          #...
        }

        # create log file
        log_path = Rails.root.join(AVAILITY_LOG_PATH)
        Dir.mkdir(log_path) unless Dir.exist?(log_path)
        log = Logger.new("#{log_path}/availity_#{Time.current.strftime('%m-%d-%Y')}.log")
        log.info("****** START CLAIM STATUS UPDATE PROCESS ******")

        headers = rows[0]
        indices = { payer_idx: headers.index(PAYOR), claim_number_idx: headers.index(CLAIM_NUMBER), availity_status_idx: headers.index(AVAILITY_STATUS) }

        # get access token from Availity
        access_token = Availity::AvailityApiServices.get_access_token
        retry_claims = []

        rows.each_with_index do |claim, index|
          next if index == 0

          # loop through each field and build the list of parameters
          cmd_payer = ""
          parameters = ""
          field_mapping_list.each do |item|
            field = item[:availity_param]
            value = claim[headers.index(item[:data_field])] rescue nil
            if value.present?
              case field
              when "payer.id"
                cmd_payer = value
                if payer_mapping[cmd_payer].blank?
                  err = "Payer #{cmd_payer} missing Availity Payer Id"
                  missing_payerid_errors << err if missing_payerid_errors.exclude?(err)
                  raise err
                end
                value = payer_mapping[cmd_payer][:availity_payer_id]
              when "claimAmount"
                value = value.to_f.round(2)
              when "patient.genderCode"
                value = "M" if value == "1"
                value = "F" if value == "0"
              end
            end
            parameters = parameters.blank? ? "#{field}=#{value}" : "#{parameters}&#{field}=#{value}"
          end

          # additional fields required by Availity API but not in S3 data file
          parameters = "#{parameters}&providers.lastName=#{payer_mapping[cmd_payer][:provider_last_name]}&submitter.lastName=#{payer_mapping[cmd_payer][:submitter_last_name]}&submitter.id=#{payer_mapping[cmd_payer][:provider_submitter_id]}"

          # get claim status by required parameters
          url = "https://api.availity.com/availity/v1/claim-statuses?#{parameters}"
          get_status(claim, access_token, url, retry_claims, indices, claim_status_errors, log)
        rescue => e
          log.error(e.message)
        end

        # for claim status requests where Availity has not received a response from the payer system,
        # follow up with get claim status by id to get the actual status of the claim
        2.times do
          sleep 4
          retries = retry_claims
          retry_claims = []
          retries.each do |item|
            # get claim status by Availity id
            url = "https://api.availity.com/availity/v1/claim-statuses/#{item[:availity_id]}"
            get_status(item[:claim], access_token, url, retry_claims, indices, claim_status_errors, log)
          rescue => e
            log.error(e.message)
          end
        end

        log.info("****** END CLAIM STATUS UPDATE PROCESS ******")
      end

      private

      def get_status(claim, access_token, url, retry_claims, indices, claim_status_errors, log)
        # send Availity API request to get claim status
        response = Availity::AvailityApiServices.get_claim_data(access_token, url)
        if response.code == "401"
          # access token expired so create a new one and resend Availity API request
          access_token = Availity::AvailityApiServices.get_access_token
          response = Availity::AvailityApiServices.get_claim_data(access_token, url)
        end

        resp_data = JSON.parse(response.body)
        case response.code
        when "200", "202"
          resp_claim = resp_data["claimStatuses"].first
          if (resp_claim["status"] == "In Progress" && resp_claim["statusCode"] == "0") || resp_claim["statusDetails"].blank?
            # Availity is in the process of retrieving the claim status from the health plan (payer system)
            # get Availity id to obtain the actual status of the claim later
            retry_claims << { claim: claim, availity_id: resp_claim["id"] }
          else
            # Availity successfully retrieved an existing claim status from the health plan (payer system)
            claim[indices[:availity_status_idx]] = resp_claim["statusDetails"]["status"]
          end
        else
          err = { claim_number: claim[indices[:claim_number_idx]], payer: claim[indices[:payer_idx]], error: "#{response.code}-#{response.message}" }
          err[:details] = response.code == "400" ? resp_data["errors"]&.map { |e| e.slice("field", "errorMessage") } : response
          claim_status_errors << err
          log.error(err)
        end
      end
    end
  end
end
