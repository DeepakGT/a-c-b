module Snowflake
  module SeedStaffDataOperation
    class << self
      def call(username, password)
        seed_staff_data(username, password)
      end

      private

      def seed_staff_data(username, password)
        db = Snowflake::SetDatabaseAndWarehouseService.call(username, password)
        staff_rosters = Snowflake::GetStaffRosterDataService.call(db)

        staff_rosters.each do |staff_roster|
          staff = Staff.find_or_initialize_by(email: staff_roster['EMAIL'], dob: staff_roster['DOB']&.to_time&.strftime('%Y:%m:%d'), hired_at: staff_roster['HIREDDATE']&.to_time&.strftime('%Y:%m:%d'), first_name: staff_roster['STAFFFIRSTNAME'], last_name: staff_roster['STAFFLASTNAME'], terminated_on: staff_roster['TERMINATEDDATE']&.to_time&.strftime('%Y:%m:%d'))
          staff.status = staff_roster['ACTIVE']=='ACTIVE' ? 'active' : 'inactive'
          staff.gender = staff_roster['GENDER']=='Female' ? 'female' : 'male'
          staff.job_type = staff_roster['PARTFULLTIME']=='Full Time' ? full_time : part_time
          # role
          staff.role = Role.find_by(name: staff_roster['JOBTITLE'].downcase)
          staff.save(validate: false)

          if staff_roster['AGENCYNAME'].present?
            clinic_name = staff_roster['AGENCYNAME'].downcase
            clinic = Clinic.where('lower(name) = ? OR lower(aka) = ?', clinic_name, clinic_name)&.first
            if clinic.present?
              staff_clinic = staff.staff_clinics.new(clinic_id: clinic.id, is_home_clinic: true)
              staff_clinic.save(validate: false)
            end
          end

          address = Address.find_or_initialize_by(addressable_id: staff.id, addressable_type: 'User')
          address.city = staff_roster['CITY']
          address.state = staff_roster['STATE']
          address.zipcode = staff_roster['ZIP']
          address.save(validate: false)

          phone_number_array = []
          phone_number_array.push(staff_roster['PHONE1']) if staff_roster['PHONE1'].present?
          phone_number_array.push(staff_roster['PHONE2']) if staff_roster['PHONE2'].present?
          phone_number_array.push(staff_roster['PHONE3']) if staff_roster['PHONE3'].present?
          phone_number_array.push(staff_roster['PHONE4']) if staff_roster['PHONE4'].present?
          if phone_number_array.present?
            phone_number_array.each do |phone_number|
              phone_type_number = phone_number.split(' ')
              staff_phone_number = staff.phone_numbers.new 
              case phone_type_number.first
              when 'Mobile'
                staff_phone_number.phone_type = 'mobile'
                staff_phone_number.number = phone_type_number.count<=2 ? phone_type_number.last : "#{phone_type_number[1]} #{phone_type_number[2]}"
              when 'Home'
                staff_phone_number.phone_type = 'home'
                staff_phone_number.number = phone_type_number.count<=2 ? phone_type_number.last : "#{phone_type_number[1]} #{phone_type_number[2]}"
              when 'Work'
                staff_phone_number.phone_type = 'work'
                staff_phone_number.number = phone_type_number.count<=2 ? phone_type_number.last : "#{phone_type_number[1]} #{phone_type_number[2]}"
              else
                staff_phone_number.phone_type = 'other'
                staff_phone_number.number = phone_number
              end
              staff_phone_number.save(validate: false)
            end
          end
        end
      end
    end
  end
end
