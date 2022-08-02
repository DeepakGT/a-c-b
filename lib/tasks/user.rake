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

  desc "Add system administrator"
  task add_system_administrator: :environment do
    role = Role.new(name: 'system_administrator', permissions: ['super_admins_view', 'super_admins_update'])
    role.id = Role.last.id + 1
    role.save(validate: false)

    User.find_or_initialize_by(email: "aba_emr_sa@abacenters.com") do |u|
      u.first_name = 'aba-emr-sa'
      u.password = 'Welcome123!'
      u.password_confirmation = 'Welcome123!'
      u.role = role
      u.save(validate: false)
    end
  end
end
