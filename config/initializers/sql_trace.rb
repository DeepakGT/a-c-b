if Rails.env.development?
    ActiveRecordQueryTrace.enabled = true
    # Optional: other gem config options go here
    ActiveRecordQueryTrace.colorize = :green
end