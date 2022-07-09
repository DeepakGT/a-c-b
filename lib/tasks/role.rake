namespace :role do
  desc "Add client care coordinator role"
  task add_client_care_coorinator: :environment do
    Role.find_or_create_by!(name: 'client_care_coordinator')
  end

  desc "Rename aba_admin to executive_director"
  task rename_aba_admin: :environment do
    Role.find_by(name: 'aba_admin').update(name: 'executive_director')
  end
end
