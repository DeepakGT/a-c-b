namespace :setting do
  desc "Add welcome note"
  task add_welcome_note: :environment do
    Setting.find_or_create_by!(welcome_note: 'Welcome!')
  end
end
