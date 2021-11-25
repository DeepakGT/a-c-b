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

  # credentials
  Credential.destroy_all
  credentials_data = [{credential_type: 'education',name: "Bachelor's Degree", description: 'The holder has completed a four year college program.', lifetime: true},
                  {credential_type: 'education',name: "Master's Degree", description: 'The holder has completed a four year college program.', lifetime: true},
                  {credential_type: 'education',name: 'Ph.D.', description: 'The holder has completed a doctorate program.', lifetime: true},
                  {credential_type: 'education',name: "Associate's Degree", description: 'The contractor has signed agreement', lifetime: true},
                  {credential_type: 'education',name: 'High School Diploma', description: 'The holder has a high school diploma', lifetime: true},
                  {credential_type: 'certification',name: 'Board Certifield Behavior Analyst', description: 'The holder is a board certified behavior analyst', lifetime: false},
                  {credential_type: 'certification',name: 'Board Certifield Assistant Behavior Analyst', description: 'The holder is a board certified assistant behavior analyst', lifetime: false},
                  {credential_type: 'other',name: 'Auto Insurance', description: "Employee's current auto insurance", lifetime: false},
                  {credential_type: 'education',name: 'CPR', description: 'The holder has completed CPR training', lifetime: false},
                  {credential_type: 'certification',name: 'First Aid Certification', description: 'The holder has completed First Aid training', lifetime: false},
                  {credential_type: 'certification',name: '30 Day Competency', description: 'The holder has completed 30 day RBT competency', lifetime: false},
                  {credential_type: 'education',name: '60 Day Competency', description: 'The holder has completed 60 day RBT competency', lifetime: false},
                  {credential_type: 'education',name: '90 Day Competency', description: 'The holder has completed 90 day RBT competency', lifetime: false},
                  {credential_type: 'certification',name: 'LABA', description: '', lifetime: false}]
  credentials_data.each do |data|
    Credential.create(data)
  end

  # funding sources
  FundingSource.destroy_all
  funding_sources_data = [{name: 'cigna'},
                          {name: 'cigna'},
                          {name: 'cigna'},
                          {name: 'cigna'},
                          {name: 'cigna'},
                          {name: 'cigna'},
                          {name: 'cigna'},
                          {name: 'cigna'},
                          {name: 'cigna'},
                          {name: 'cigna'},
                          {name: 'cigna'},
                          {name: 'cigna'}]
  funding_sources_data.each do |data|
    FundingSource.create(data)
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
