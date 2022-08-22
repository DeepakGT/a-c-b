class AddAvailitySourceAndTargetFile < ActiveRecord::Migration[6.1]
  def change
    source_file_key = "availity_status_s3_source"
    target_file_key = "availity_status_s3_target"

    config_rec = ApplicationConfig.find_by(config_key: source_file_key)
    if config_rec.blank?
      ApplicationConfig.create!(config_key: source_file_key, config_value: "availity/collab-pending-availity.csv")
    end

    config_rec = ApplicationConfig.find_by(config_key: target_file_key)
    if config_rec.blank?
      ApplicationConfig.create!(config_key: target_file_key, config_value: "availity_statuses/collab-availity-done.csv")
    end
  end
end
