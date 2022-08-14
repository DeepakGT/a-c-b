require 'csv'

namespace :import_availity_mapping_csv do
  desc "Create Field Mapping"
  task create_field_mapping: :environment do
    field_mapping_key = "availity_field_mapping"
    field_mapping = []
    CSV.foreach(Rails.root.join("lib/Availity/field_mapping.csv"), headers: true) do |row|
      field_mapping << { availity_param: row["availity_param"], data_field: row["data_field"] }
    end
    config_rec = ApplicationConfig.find_by(config_key: field_mapping_key)
    if config_rec.present?
      config_rec.update!(config_value: field_mapping.to_json)
    else
      ApplicationConfig.create!(config_key: field_mapping_key, config_value: field_mapping.to_json)
    end
  end

  desc "Create Payer Mapping"
  task create_payer_mapping: :environment do
    payer_mapping_key = "availity_payer_mapping"
    payer_mapping = {}
    CSV.foreach(Rails.root.join("lib/Availity/payer_mapping.csv"), headers: true) do |row|
      payer_mapping[row["cmd_payer_id"]] = {
        availity_payer_id: row["availity_payer_id"],
        submitter_id: row["submitter_id"],
        submitter_last_name: row["submitter_last_name"],
        provider_last_name: row["provider_last_name"]
      } unless payer_mapping.key?(row["cmd_payer_id"])
    end
    config_rec = ApplicationConfig.find_by(config_key: payer_mapping_key)
    if config_rec.present?
      config_rec.update!(config_value: payer_mapping.to_json)
    else
      ApplicationConfig.create!(config_key: payer_mapping_key, config_value: payer_mapping.to_json)
    end
  end
end
