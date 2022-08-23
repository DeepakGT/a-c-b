namespace :update_staff_client do
  desc "Update staff and client to remove trailing spaces on their first and last name"
  task update_first_and_last_name: :environment do
    clients = Client.all
    cliens.each do |client|
      client.first_name = client.first_name.strip
      client.last_name = client.last_name.strip
      client.save
    end

    staffs = Staff.all
    staff.each do |staff|
      staff.first_name = staff.first_name.strip
      staff.last_name = staff.last_name.strip
      staff.save
    end
  end
end
  