namespace :snowflake do
  desc "Seed staff, client, client_enrollment, client_enrollment_service, scheduling from snowflake"
  task :seed_snowflake_data, [:username, :password] => [:environment] do |t, args|
    # seed staff data
    Snowflake::SeedStaffDataOperation.call(args[:username], args[:password])

    # seed client data
    Snowflake::SeedClientDataOperation.call(args[:username], args[:password])

    # seed bcba_id for clients data
    Snowflake::SeedBcbasForClientOperation.call(args[:username], args[:password])

    # seed client enrollment data
    Snowflake::SeedClientEnrollmentDataOperation.call(args[:username], args[:password])

    # seed client enrollment service data
    Snowflake::SeedClientEnrollmentServiceDataOperation.call(args[:username], args[:password])

    # seed scheduling data
    Snowflake::SeedSchedulingDataOperation.call(args[:username], args[:password])
  end
end
