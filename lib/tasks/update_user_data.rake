namespace :update_user_data do
  desc "Update user address and phone numbers"
  task update_addr_phone_number: :environment do
    user_data = User.all
    user_data.each do |user|
      puts "user #{user}"
      user.address = Address.new
      user.address.line1 = 'Test line1'
      user.address.line2 = 'Test line2'
      user.address.line3 = 'Test line3'
      user.address.zipcode = '92222' 
      user.address.state = 'Test State'
      user.address.city = 'Test City'
      user.address.country = 'Test Country'
      user.phone_numbers = [PhoneNumber.new]
      user.phone_numbers.each do |ph|
        ph.phone_type = 'mobile'
        ph.number = '9876543210'
      end
      user.save
      puts "user after update #{user}"
    end
  end
end
