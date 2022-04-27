namespace :snowflake do
  desc "Seed staff, client, client_enrollment, client_enrollment_service, scheduling from snowflake"
  task :seed_snowflake_data, [:username, :password] => [:environment] do |t, args|
    # seed staff data
    Scheduling.delete_all
    ClientEnrollmentService.delete_all
    ClientEnrollment.delete_all
    Client.delete_all
    UserRole.where(id: Staff.ids).destroy_all
    StaffClinic.where(staff_id: Staff.ids).delete_all
    Address.where(addressable_type: 'User', addressable_id: Staff.ids).delete_all
    PhoneNumber.where(phoneable_type: 'User', phoneable_id: Staff.ids).delete_all
    Staff.delete_all
    
    puts "Seed staff data is in progress."
    Snowflake::SeedStaffDataOperation.call(args[:username], args[:password])
    puts "Seed staff data is completed. Thank You!"

    # seed client data
    puts "Seed client data is in progress."
    Snowflake::SeedClientDataOperation.call(args[:username], args[:password])

    # seed bcba_id for clients data
    Snowflake::SeedBcbasForClientOperation.call(args[:username], args[:password])
    puts "Seed client data is completed. Thank You!"

    # seed client enrollment data
    puts "Seed client enrollment data is in progress."
    Snowflake::SeedClientEnrollmentDataOperation.call(args[:username], args[:password])
    puts "Seed client enrollment data is completed. Thank You!"

    # seed client enrollment service data
    puts "Seed client enrollment service data is in progress."
    Snowflake::SeedClientEnrollmentServiceDataOperation.call(args[:username], args[:password])
    puts "Seed client enrollment service data is completed. Thank You!"

    # seed scheduling data
    puts "Seed scheduling data is in progress."
    Snowflake::SeedSchedulingDataOperation.call(args[:username], args[:password])
    puts "Seed scheduling data is completed. Thank You!"
  end
end
