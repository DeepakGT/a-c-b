module Availity
  module ProcessClaimsOperation
    AVAILITY_LOG_PATH = "log/availity".freeze
    AVAILITY_STATUS = "AVAILITY_STATUS".freeze
    PAYOR_ID = "PAYORID".freeze
    PROVIDER_SEQ = "PROVIDERSEQ".freeze
    
    class << self
      def process_claims(rows, field_mapping_key, payer_mapping_key, provider_mapping_key)
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
        #   "12857650" => { "availity_payer_id": "UMR" },
        #   "12966144" => { "availity_payer_id": "BCBSF" }
        # }
        config_value = ApplicationConfig.find_by(config_key: payer_mapping_key).config_value rescue nil
        payer_mapping = JSON.parse(config_value) rescue {}

        # get the provider mapping where each key is a Provider Sequence
        # example:
        # {
        #   "10144208" => { "submitter_id": "848414", "submitter_last_name": "ABA CENTERS OF AMERICA LLC", "provider_last_name": "ABA CENTERS OF AMERICA LLC" },
        #   "10143647" => { "submitter_id": "1000922", "submitter_last_name": "ABA CENTERS OF AMERICA", "provider_last_name": "ABA CENTERS OF AMERICA" }
        # }
        config_value = ApplicationConfig.find_by(config_key: provider_mapping_key).config_value rescue nil
        provider_mapping = JSON.parse(config_value) rescue {}

        # create log file
        log_path = Rails.root.join(AVAILITY_LOG_PATH)
        Dir.mkdir(log_path) unless Dir.exist?(log_path)
        log = Logger.new("#{log_path}/availity_#{Time.current.strftime('%m-%d-%Y')}.log")
        log.info("****** START CLAIM STATUS UPDATE PROCESS ******")

        # get access token from Availity
        access_token = Availity::AvailityApiServices.get_access_token
        retry_claims = []
        missing_payerid_errors = []

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
                  err = "Not found Availity Payer Id for CollabMD Payer #{cmd_payer}"
                  claim[AVAILITY_STATUS] = { "error" => err, "details" => err }
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
            provider_seq = claim[PROVIDER_SEQ]
            parameters = "#{parameters}&providers.lastName=#{provider_mapping[provider_seq]['provider_last_name']}&submitter.lastName=#{provider_mapping[provider_seq]['submitter_last_name']}&submitter.id=#{provider_mapping[provider_seq]['submitter_id']}"

            # get claim status by required parameters
            url = "#{Availity::AvailityApiServices::AVAILITY_CLAIM_STATUS_URL}?#{parameters}"
            get_status(claim, access_token, url, retry_claims, log)
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
            url = "#{Availity::AvailityApiServices::AVAILITY_CLAIM_STATUS_URL}/#{item[:availity_id]}"
            get_status(item[:claim], access_token, url, retry_claims, log)
          rescue => e
            log.error("#{e.message} => #{e.backtrace}")
          end
        end

        log.info("****** END CLAIM STATUS UPDATE PROCESS ******")
      end

      private

      def get_status(claim, access_token, url, retry_claims, log)
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
          err = { "payer_id" => claim[PAYOR_ID], "provider_seq" => claim[PROVIDER_SEQ], "error" => "#{response.code}-#{response.message}" }
          err["details"] = response.code == "400" ? resp_data["errors"]&.map { |e| e.slice("field", "errorMessage") } : response
          claim[AVAILITY_STATUS] = err.slice("error", "details")
          log.error(err)
        end
      end
    end
  end
end
