namespace :service do
  desc "Update early code flag"
  task update_is_early_code: :environment do
    services = Service.where(display_code: ['99997', '99998', '99999', '98888'])
    services.update_all(is_early_code: true)
  end
end
