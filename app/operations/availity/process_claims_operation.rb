module Availity
  module ProcessClaimsOperation
    AVAILITY_LOG_PATH = "log/availity".freeze
    AVAILITY_STATUS = "AVAILITY_STATUS".freeze
    CLAIM_NUMBER = "CLAIMNUMBER".freeze
    PAYORID = "PAYORID".freeze
    
    class << self
      def process_claims(rows, missing_payerid_errors, claim_status_errors, field_mapping_key, payer_mapping_key)
        # get the field mapping between Availity API parameters and S3 data fields
        # example:
        # [
        #   {"availity_param":"payer.id","data_field":"PAYORID"},
        #   {"availity_param":"providers.npi","data_field":"CORP_NPI"},
        #   {"availity_param":"patient.genderCode","data_field":"GENDERCODE"}
        # ]
        config_value = ApplicationConfig.find_by(config_key: field_mapping_key).config_value rescue nil
        field_mapping = JSON.parse(config_value) rescue []

        # get the payer mapping between CollabMD and Availity where each key is a CollabMD Payer Id
        # example:
        # {
        #   "12857650" => { "availity_payer_id": "UMR", "submitter_id": "837903", "submitter_last_name": "ABA CENTERS OF FLORIDA", "provider_last_name": "ABA CENTERS OF FLORIDA" },
        #   "12966144" => { "availity_payer_id": "BCBSF", "submitter_id": "837903", "submitter_last_name": "ABA CENTERS OF AMERICA", "provider_last_name": "ABA CENTERS OF AMERICA" }
        # }
        config_value = ApplicationConfig.find_by(config_key: payer_mapping_key).config_value rescue nil
        payer_mapping = JSON.parse(config_value) rescue {}

        # create log file
        log_path = Rails.root.join(AVAILITY_LOG_PATH)
        Dir.mkdir(log_path) unless Dir.exist?(log_path)
        log = Logger.new("#{log_path}/availity_#{Time.current.strftime('%m-%d-%Y')}.log")
        log.info("****** START CLAIM STATUS UPDATE PROCESS ******")

        # get access token from Availity
        access_token = Availity::AvailityApiServices.get_access_token
        retry_claims = []

        rows.each do |claim|
          # loop through each field and build the list of parameters
          cmd_payer = ""
          parameters = ""
          field_mapping.each do |item|
            field = item["availity_param"]
            value = claim[item["data_field"]] rescue nil
            if value.present?
              case field
              when "payer.id"
                cmd_payer = value
                if payer_mapping[cmd_payer].blank?
                  value = ""
                  err = "CollabMD Payer #{cmd_payer} missing Availity Payer Id"
                  if missing_payerid_errors.exclude?(err)
                    missing_payerid_errors << err
                    log.error(err)
                  end
                else
                  value = payer_mapping[cmd_payer]["availity_payer_id"]
                end
              when "claimAmount"
                value = value.to_f.round(2)
              when "patient.genderCode"
                value = "M" if value == "1"
                value = "F" if value == "0"
              end
            end
            parameters = parameters.blank? ? "#{field}=#{value}" : "#{parameters}&#{field}=#{value}"
          end

          if payer_mapping[cmd_payer].present?
            # additional fields required by Availity API but not in S3 data file
            parameters = "#{parameters}&providers.lastName=#{payer_mapping[cmd_payer]['provider_last_name']}&submitter.lastName=#{payer_mapping[cmd_payer]['submitter_last_name']}&submitter.id=#{payer_mapping[cmd_payer]['submitter_id']}"

            # get claim status by required parameters
            url = "https://api.availity.com/availity/v1/claim-statuses?#{parameters}"
            get_status(claim, access_token, url, retry_claims, claim_status_errors, log)
          end
        rescue => e
          log.error("#{e.message} => #{e.backtrace}")
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
            get_status(item[:claim], access_token, url, retry_claims, claim_status_errors, log)
          rescue => e
            log.error("#{e.message} => #{e.backtrace}")
          end
        end

        log.info("****** END CLAIM STATUS UPDATE PROCESS ******")
      end

      private

      def get_status(claim, access_token, url, retry_claims, claim_status_errors, log)
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
          if resp_claim["statusDetails"].blank? || (resp_claim["status"] == "In Progress" && resp_claim["statusCode"] == "0")
            # Availity is in the process of retrieving the claim status from the health plan (payer system)
            # get Availity id to obtain the actual status of the claim later
            retry_claims << { claim: claim, availity_id: resp_claim["id"] }
          else
            # Availity successfully retrieved an existing claim status from the health plan (payer system)
            claim[AVAILITY_STATUS] = resp_claim["statusDetails"]
          end
        else
          err = { claim_number: claim[CLAIM_NUMBER], payer: claim[PAYORID], error: "#{response.code}-#{response.message}" }
          err[:details] = response.code == "400" ? resp_data["errors"]&.map { |e| e.slice("field", "errorMessage") } : response
          claim_status_errors << err
          log.error(err)
        end
      end
    end
  end
end
