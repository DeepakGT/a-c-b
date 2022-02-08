namespace :role do
  desc "Add client care coordinator role"
  task add_client_care_coorinator: :environment do
    Role.find_or_create_by!(name: 'client_care_coordinator')
  end
end
