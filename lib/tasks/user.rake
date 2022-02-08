namespace :user do
  desc "Add super admin user"
  task add_super_admin: :environment do
    Role.find_or_create_by!(name: 'super_admin')
    
    User.find_by(email: "super_admin_user@yopmail.com").destroy
    User.find_or_initialize_by(email: "super_admin_user@yopmail.com") do |u|
      u.first_name, u.last_name = Faker::Name.unique.name.split(' ')
      u.password = 'SuperAdmin@123'
      u.role = Role.find_by(name: 'super_admin')
      u.save(validate: false)
    end
  end
end
