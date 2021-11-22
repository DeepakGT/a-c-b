puts "Data seed is in progress..."

ActiveRecord::Base.transaction do
  # Roles
  Role.names.each_key do |role_name|
    Role.find_or_create_by!(name: role_name)
  end

  # create two users with each role, [aba_admin' and 'administrator]
  Role.where(name: ['aba_admin', 'administrator']).each do |role|
    User.where(email: "#{role.name}_user@yopmail.com").first_or_create! do |u|
      # This block will run only on create new records
      # i.e. if record found, this block would be skip
      u.first_name, u.last_name = Faker::Name.unique.name.split(' ')
      u.password = '123456'
      u.role = role
    end
  end

  # Organization
  org = Organization.find_or_create_by!(name: 'org1', admin_id: Role.aba_admin.first.users.first.id)

  # Clinic
  clinic = Clinic.find_or_create_by!(name: 'clinic1', organization_id: org.id)

  # Will create two user for each each role, ['bcba', 'rbt', 'billing']
  Role.where(name: ['bcba', 'rbt', 'billing']).each do |role|
    2.times do |i|
      User.where(email: "#{role.name}_user#{i+1}@yopmail.com").first_or_create! do |u|
        # This block will run only on create new records
        # i.e. if record found, this block would be skip
        u.first_name, u.last_name = Faker::Name.unique.name.split(' ')
        u.password = '123456'
        u.role = role
        u.clinic = clinic
      end
      # end of user block
    end
    # end of times block
  end
  # end of roll block
end
# end of transaction block

puts "Data seed completed. Thank You!"
