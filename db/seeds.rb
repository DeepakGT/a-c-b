puts "Data seed is in progress..."
password = '123456'

# Will create two user for each role
Role.names.keys.each do |role|
  2.times do |i|
    User.where(email: "#{role}_user#{i+1}@yopmail.com").first_or_create do |u|
      # This block will run only on create new records
      # i.e. if record found, this block would be skip
      u.first_name, u.last_name = Faker::Name.unique.name.split(' ')
      u.password = password
      u.role = Role.send(role).first || Role.new(name: role)
    end
  end
end
puts "Data seed completed. Thank You!"
