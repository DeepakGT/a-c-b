namespace :db do
  desc "Seed production data"
  task seed_production: :environment do
    puts "Production data seed is in progress..."
    ActiveRecord::Base.transaction do
      # Role
      Role.find_or_create_by!(name: 'super_admin')
      Role.find_or_create_by!(name: 'executive_director')
      Role.find_or_create_by!(name: 'administrator')
      Role.find_or_create_by!(name: 'bcba')
      Role.find_or_create_by!(name: 'rbt')
      Role.find_or_create_by!(name: 'billing')
    
      # create a user with role super_admin
      User.where(email: "super_admin_user@yopmail.com").first_or_create! do |u|
        # This block will run only on create new records
        # i.e. if record found, this block would be skip
        u.first_name, u.last_name = Faker::Name.unique.name.split(' ')
        u.password = Rails.application.credentials.dig(:default_super_admin_password)
        u.role = Role.find_by(name: 'super_admin')
      end
    
      # Country List
      Country.delete_all
      ISO3166::Country.all.each do |country|
        Country.create(name: country.name, code: country.alpha3)
      end
    end
    puts "Production data seed completed. Thank You!"
  end
end
