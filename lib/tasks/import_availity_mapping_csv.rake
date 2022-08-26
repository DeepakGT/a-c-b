require 'csv'

namespace :import_availity_mapping_csv do
  desc "Create Field Mapping"
  task create_field_mapping: :environment do
    field_mapping_key = "availity_field_mapping"
    field_mapping = []
    CSV.foreach(Rails.root.join("lib/Availity/field_mapping.csv"), headers: true) do |row|
      field_mapping << { availity_param: row["availity_param"].strip, data_field: row["data_field"].strip }
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
      payer_mapping[row["cmd_payer_id"].strip] = {
        availity_payer_id: row["availity_payer_id"].split("/")&.first&.strip
      } unless payer_mapping.key?(row["cmd_payer_id"].strip)
    end
    config_rec = ApplicationConfig.find_by(config_key: payer_mapping_key)
    if config_rec.present?
      config_rec.update!(config_value: payer_mapping.to_json)
    else
      ApplicationConfig.create!(config_key: payer_mapping_key, config_value: payer_mapping.to_json)
    end
  end

  desc "Create Provider Mapping"
  task create_provider_mapping: :environment do
    provider_mapping_key = "availity_provider_mapping"
    provider_mapping = {}
    CSV.foreach(Rails.root.join("lib/Availity/provider_mapping.csv"), headers: true) do |row|
      provider_mapping[row["cmd_provider_seq"].strip] = {
        submitter_id: row["submitter_id"].strip,
        submitter_last_name: row["submitter_last_name"].strip,
        provider_last_name: row["provider_last_name"].strip
      } unless provider_mapping.key?(row["cmd_provider_seq"].strip)
    end
    config_rec = ApplicationConfig.find_by(config_key: provider_mapping_key)
    if config_rec.present?
      config_rec.update!(config_value: provider_mapping.to_json)
    else
      ApplicationConfig.create!(config_key: provider_mapping_key, config_value: provider_mapping.to_json)
    end
  end

  desc "Create Active 276-Type Payers"
  task create_active_276_type_payers: :environment do
    active_payers_key = "availity_active_276_type_payers"
    active_payers = {}
    CSV.foreach(Rails.root.join("lib/Availity/active_276_type_payers.csv"), headers: true) do |row|
      active_payers[row["availity_payer_id"].strip] = true unless active_payers.key?(row["availity_payer_id"].strip)
    end
    config_rec = ApplicationConfig.find_by(config_key: active_payers_key)
    if config_rec.present?
      config_rec.update!(config_value: active_payers.to_json)
    else
      ApplicationConfig.create!(config_key: active_payers_key, config_value: active_payers.to_json)
    end
  end
end
